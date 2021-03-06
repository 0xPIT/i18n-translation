# i18n JavaScript Internationalization

i18n is a JavaScript for internationalization

### Options

```javascript
i18n.addOptions({
    debug: true, // => debug mode to highlight translations, default = false
    locale: 'en-US', // => which locale should be used?
    pattern: /#\{(.*?)\}+/g // => pattern for using variables in the translations e.g. hello #{0} => Hello Dude, default = #{}
});
```

### Translations

```javascript
i18n.setTranslations({
    'en-US': {
        'hello': 'helloooooo dude',
        'Das ist eine Übersetzung': 'This is a translation',
        'logged_in.hello': 'Holla #{0}'
    }
});
```

### Usage

```javascript
__.t('hello') // => helloooooo dude
__.t('logged_in.hello', 'Dudette') // => Holla Dudette
// or
i18n.t('hello') // => helloooooo dude
i18n.t('logged_in.hello', 'Dudette') // => Holla Dudette
```

## i18n translation compiling script 

compile-translate.rb to compile a translation file e.g. a Rails i18n *.yml file

```yml
en-US:
  hello: helloooooo dude
  Das ist eine Übersetzung: This is a translation
  logged_in:
    hello: Holla #{0}
    dudes: Your Dudes #{0}, #{1} and #{2} are ready.
    preferences:
        language: Choose Language:
        dance: D.A.N.C.E. #{0}
        dancing: D.A.N.C.I.N.G. %{0}
        dancer: D.A.N.C.E.R. %s
```

You can use this script to create an JavaScript file with the translations from your input.

```ruby
ruby compile-translate.rb --files en-US.yml --locales en-US --export_dir translations
```

### Parameters for usage

```ruby
    -f, --files FILES                files to convert: [file 1,file 2]
    -l, --locales LOCALES            locales for files: [locale 1,locale 2]
        --export_dir FOLDER
                                     export dir for converted files
    -v, --verbose                    Output more information
    -h, --help                       Show this message
```

### LICENSE
Released under MIT License.