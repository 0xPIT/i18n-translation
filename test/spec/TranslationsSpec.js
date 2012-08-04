/*globals describe: false, it: false, expect: false, i18n: false*/
describe("Translations Suite", function () {
    it("should show the translation key if no translation is available", function () {
        expect(__.t('Hola... Que Pasa')).toBe('Hola... Que Pasa');
    });

    it("should translate the key if it is translated", function () {
        i18n.addOptions({
            locale: 'en-US'
        });
        expect(__.t('hello')).toBe('helloooooo dude');
        expect(__.t('hello')).toBe('helloooooo dude', 'not used string');
        expect(__.t('Das ist eine Übersetzung')).toBe('This is a translation');
        expect(__.t('logged_in.hello', 'Dudes')).toBe('Holla Dudes');
    });

    it("should work with prefixes in the translation key", function () {
        i18n.addOptions({
            locale: 'en-US'
        });
        expect(__.t('logged_in.hello', 'Dudes')).toBe('Holla Dudes');
        expect(__.t('logged_in.preferences.language')).toBe('Choose Language:');
        expect(__.t('logged_in.preferences.dance', 'Dude')).toBe('D.A.N.C.E. Dude');
    });

    it("should work without translations", function () {
        i18n.addOptions({
            locale: 'de-DE'
        });
        expect(__.t('logged_in.hello', 'Dudes')).toBe('logged_in.hello');
        expect(__.t('logged_in.preferences.language')).toBe('logged_in.preferences.language');
        expect(__.t('logged_in.preferences.dance', 'Dude')).toBe('logged_in.preferences.dance');
    });

});

describe("Translation shortcut Suite", function () {
    it("should work with __.t()", function () {
        i18n.addOptions({
            locale: 'en-US'
        });
        expect(__.t('Hola... Que Pasa')).toBe('Hola... Que Pasa');
        expect(__.t('hello')).toBe('helloooooo dude');
    });

    it("should work with i18n.t()", function () {
        i18n.addOptions({
            locale: 'en-US'
        });
        expect(i18n.t('Hola... Que Pasa')).toBe('Hola... Que Pasa');
        expect(i18n.t('hello')).toBe('helloooooo dude');
    });

});

describe("Translation with other patterns", function () {
    it("shoud work with the default pattern #{s}", function () {
        i18n.addOptions({
            locale: 'en-US'
        });
        expect(__.t('logged_in.preferences.dance', 'Dude')).toBe('D.A.N.C.E. Dude');
    });

    it("shoud work with #{s}", function () {
        i18n.addOptions({
            locale: 'en-US',
            pattern: /#\{(.*?)\}+/g
        });
        expect(__.t('logged_in.preferences.dance', 'Dude')).toBe('D.A.N.C.E. Dude');
    });

    it("shoud work with %{s}", function () {
        i18n.addOptions({
            locale: 'en-US',
            pattern: /%\{(.*?)\}+/g
        });
        expect(__.t('logged_in.preferences.dancing', 'Dude')).toBe('D.A.N.C.I.N.G. Dude');
    });

    it("shoud work with %s", function () {
        i18n.addOptions({
            locale: 'en-US',
            pattern: /%(.*?)+/g
        });
        expect(__.t('logged_in.preferences.dancer', 'Dude')).toBe('D.A.N.C.E.R. Dude');
    });
});

describe("Translation Debug Suite", function () {
    it("should do nothing if everything is fine", function () {
        i18n.addOptions({
            locale: 'en-US',
            debug: true
        });
        expect(i18n.t('hello')).toBe('helloooooo dude');
    });


    it("should highlight if translations are missing", function () {
        i18n.addOptions({
            locale: 'en-US',
            debug: true,
            pattern: /#\{(.*?)\}+/g
        });
        expect(__.t('Hola... Que Pasa')).toBe('<span class="" title="Missing: translation" style="color: red; font-weight: bold;"">Hola... Que Pasa</span>');
        expect(__.t('Hola')).toBe('<span class="" title="Missing: translation" style="color: red; font-weight: bold;"">Hola</span>');
    });

    it("should show were attributes are used", function () {
        i18n.addOptions({
            locale: 'en-US',
            debug: true,
            pattern: /#\{(.*?)\}+/g
        });
        expect(__.t('logged_in.hello', 'Dude')).toBe('Holla <span class="" title="Attribute: #{0}" style="font-weight: bold;"">Dude</span>');
    });

    it("should show were attributes are missing", function () {
        i18n.addOptions({
            locale: 'en-US',
            debug: true,
            pattern: /#\{(.*?)\}+/g
        });
        expect(__.t('logged_in.hello')).toBe('<span class="" title="Missing: #{0}" style="color: red; font-weight: bold;"">Holla </span>');
    });

});