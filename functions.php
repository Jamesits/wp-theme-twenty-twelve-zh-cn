<?php
/**
 * Twenty Twelve functions and definitions.
 *
 * Sets up the theme and provides some helper functions, which are used
 * in the theme as custom template tags. Others are attached to action and
 * filter hooks in WordPress to change core functionality.
 *
 * When using a child theme (see https://codex.wordpress.org/Theme_Development and
 * https://codex.wordpress.org/Child_Themes), you can override certain functions
 * (those wrapped in a function_exists() call) by defining them first in your child theme's
 * functions.php file. The child theme's functions.php file is included before the parent
 * theme's file, so the child theme functions would be used.
 *
 * Functions that are not pluggable (not wrapped in function_exists()) are instead attached
 * to a filter or action hook.
 *
 * For more information on hooks, actions, and filters, @link https://codex.wordpress.org/Plugin_API
 *
 * @since Twenty Twelve zh-CN 1.0
 */
 add_action('wp_enqueue_scripts', 'theme_enqueue_styles');
 function theme_enqueue_styles()
 {
     $parent_style = 'parent-style';

     wp_enqueue_style('parent-style', get_template_directory_uri().'/style.css');
     wp_enqueue_style('han',
        get_stylesheet_directory_uri().'/bower_components/Han/dist/han.min.css',
        array($parent_style)
    );

     wp_enqueue_script('han-js', get_stylesheet_directory_uri().'/bower_components/Han/dist/han.min.js', array(), false, true);
 }

 if (!function_exists('language_attributes')) {
     /**
      * Use correct `lang` tag.
      *
      * @since Twenty Twelve zh-CN 1.0
      */
     function language_attributes()
     {
         return 'lang="zh-cmn-Hans"';
     }
 }

if (!function_exists('twentytwelve_get_font_url')) {
    /**
     * Return the Google font stylesheet URL if available.
     *
     * The use of Open Sans by default is localized. For languages that use
     * characters not supported by the font, the font can be disabled.
     *
     * @since Twenty Twelve 1.2
     *
     * @return string Font stylesheet or empty string if disabled.
     */
    function twentytwelve_get_font_url()
    {
        $font_url = '';

        /* translators: If there are characters in your language that are not supported
         * by Open Sans, translate this to 'off'. Do not translate into your own language.
         */
        if ('off' !== _x('on', 'Open Sans font: on or off', 'twentytwelve')) {
            $subsets = 'latin,latin-ext';

            /* translators: To add an additional Open Sans character subset specific to your language,
             * translate this to 'greek', 'cyrillic' or 'vietnamese'. Do not translate into your own language.
             */
            $subset = _x('no-subset', 'Open Sans font: add new subset (greek, cyrillic, vietnamese)', 'twentytwelve');

            if ('cyrillic' == $subset) {
                $subsets .= ',cyrillic,cyrillic-ext';
            } elseif ('greek' == $subset) {
                $subsets .= ',greek,greek-ext';
            } elseif ('vietnamese' == $subset) {
                $subsets .= ',vietnamese';
            }

            $query_args = array(
                'family' => 'Open+Sans:400italic,700italic,400,700',
                'subset' => $subsets,
            );
            $font_url = add_query_arg($query_args, 'https://fonts.lug.ustc.edu.cn/css');
        }

        return $font_url;
    }
}
