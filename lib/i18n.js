/*globals console: false*/
/**
 * i18n translation script v0.1
 * http://cweiss.de
 * 2012, Christopher Weiss
 * @cweissde
 *
 * licensed under the MIT
 * Date: Sat Aug 04 11:46 2012
 */

(function (global) {
    'use strict';

    // default options
    var i18n = {},
        options = {
            debug: false,
            defaultLocale: 'en-EN',
            pattern: /#\{(.*?)\}+/g,
            style: {
                missing: 'color: red; font-weight: bold;',
                used: 'font-weight: bold;'
            }
        };

    i18n.prototype = {

        /**
         * this method gets all attributes and returns the translated string 
         * @return translation
         */
        t: function () {
            this.log('i18n.t', Array.prototype.slice.call(arguments));
            var args = Array.prototype.slice.call(arguments),
                toBeTranslated = args[0],
                attributes = args.slice(1),
                locale = options.locale || options.defaultLocale,
                translation,
                localized,
                match;

            if (locale && args) {
                localized = options[locale];
                localized = (localized && localized[toBeTranslated]) ? localized[toBeTranslated] : false;
                translation = localized || toBeTranslated;

                match = this.getAttributes(translation);

                if (match) {
                    translation = this.setAttributes({
                        toBeTranslated: translation,
                        match: match,
                        attributes: attributes
                    });
                } else {
                    if (!localized) {
                        translation = this.debug({
                            translated: translation,
                            style: options.style.missing,
                            className: 'unusedParams',
                            match: 'translation'
                        });
                    }
                }

                return translation;

            } else {
                throw 'i18n: Empty. String Missing';
            }

        },

        /**
         * gets all attributes to the given key
         * @param string
         * @return {*}
         */
        getAttributes: function (string) {
            this.log('i18n.getAttributes', string);
            if (string) {
                var pattern = options.pattern;
                string = string.match(pattern);
            }

            return string;
        },

        /**
         * replaces founded attributes and returns translated string
         * @param data
         * @return {*}
         */
        setAttributes: function (data) {
            this.log('i18n.setAttributes', data);
            var translated = data.toBeTranslated,
                i = data.match.length - 1,
                attributes = data.attributes,
                match = data.match,
                attribute,
                missingStatement,
                matching;

            for (i; i >= 0; i = i - 1) {
                attribute = attributes[i] || '';

                if (options.debug) {

                    if (!missingStatement && !attribute) {
                        missingStatement = true;
                    }

                    attribute = attribute ? attribute = this.debug({
                        translated: attribute,
                        style: options.style.used,
                        className: 'usedParam',
                        match: match[i]
                    }) : '';
                }

                translated = translated.replace(match[i], attribute);
            }

            if (missingStatement) {
                translated = this.debug({
                    translated: translated,
                    style: options.style.missing,
                    className: 'unusedParams',
                    match: match
                });
            }

            return translated;
        },

        /**
         * extends the options 
         * @param options
         * @return {*}
         */
        setOptions: function (options) {
            this.log('i18n.setOptions', options);
            var args = Array.prototype.slice.call(arguments),
                i = args.length - 1,
                argument,
                args;

            for (i; i >= 0; i = i - 1) {
                args = args[i];
                for (argument in args) {
                    if (args.hasOwnProperty(argument)) {
                        options[argument] = args[argument];
                    }
                }
            }

            return options;
        },

        /**
         * public method to set the new options
         * @param newOptions
         */
        addOptions: function (newOptions) {
            this.setOptions(options, newOptions);
        },

        /**
         * add translations
         * @param translations
         */
        setTranslations: function (translations) {
            this.setOptions(options, translations);
        },

        /**
         * shows missing translations or missing attributes
         * if the debug is mode is set to true
         * @param data
         * @return {String}
         */
        debug: function (data) {
            this.log('i18n.debug', data, options);
            var translated = data.translated,
                style = data.style,
                className = data.className,
                match = data.match,
                label = (data.className === 'usedParam') ? 'Attribute: ' : 'Missing: ';

            // matching = match.join(' ').toString();
            // matching = matching.replace(match[i], '');

            return (data.translated && options.debug) ? '<span class="" ' +
                'title="' + label + match +  '" ' +
                'style="' + style + '"">' +
                translated +
                '</span>' : translated;
        },

        /**
         * logging
         * @param data
         */
        log: function (data) {
            if (options.debug && data) {
                var log = Array.prototype.slice.call(arguments);

                if (window.console) {
                    console.log(log);
                }
            }
        }

    };

    // global binding
    window.i18n = window.__ = i18n.prototype;

}( window ));