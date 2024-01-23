(function() {
    const initialize = function() {
        const prototype = Reflect.getPrototypeOf(this);
        lo.each(Reflect.getMetadataKeys(prototype), key => {
            if (lo.startsWith(key, "xf.property")) {
                const name = key.substring(12);
                const desc = Reflect.getMetadata(key, prototype);
                this[name] = desc.initializer();
            }
        });

        const type = Reflect.getPrototypeOf(this);
        const path = Reflect.getMetadata("xf:engine:view", type);
        if (path != null) {
            fx.game.bridge.component.initialize(this, path);
        }
    };

    class Component extends cc.Component {
        constructor(name) {
            super(name);
            initialize.call(this);
        }
    }

    if (cc.settings.querySettings("engine", "platform") != null && !cc.settings.querySettings("profiling", "showFPS")) {
        Component = function() {
            cc.Component.apply(this, arguments);
            initialize.call(this);
            return this;
        }
        Object.setPrototypeOf(Component, cc.Component);
        Component.prototype = Object.create(cc.Component.prototype);
        Component.prototype.constructor = Component;
    }

    Component.prototype.dispose = function() {
        fx.game.bridge.component.dispose(this);
    };

    Component.prototype.onLoad = function() {
        fx.game.bridge.component.onLoad(this);
    };

    Component.prototype.start = function() {
        fx.game.bridge.component.start(this);
    };

    Component.prototype.onEnable = function() {
        fx.game.bridge.component.onEnable(this);
    };

    Component.prototype.onDisable = function() {
        fx.game.bridge.component.onDisable(this);
    };

    const decorator = {
        class:    cc._decorator.ccclass,
        property: cc._decorator.property,
    };

    const defineType = function(info) {
        if (info.type === cc.Boolean) {
            return null;
        }

        if (info.type === cc.String) {
            return null;
        }

        if (lo.isArray(info.type)) {
            return defineType(lo.head(info.type));
        }

        if (lo.isPlainObject(info.type)) {
            const type = class {
                constructor() {
                    initialize.call(this);
                }
            };

            lo.each(info.type, (data, name) => {
                defineProperty(type.prototype, name, data);
            });

            Reflect.apply(decorator.class(info.data.class), null, [ type ]);
            return type;
        }

        return info.type;
    };

    const defineMethod = function(prototype, name) {
        prototype[name] = function(...args) {
            return fx.game.bridge.component.call(this, name, args);
        };
    };

    const defineProperty = function(prototype, name, info) {
        const data = {
            type:        defineType(info),
            displayName: name,
            multiline:   lo.get(info.data, "multiline") ?? false,
        };
        if (data.type == null) {
            delete data.type;
        }
        if (lo.startsWith(name, "xf:")) {
            data.displayName = lo.lowerFirst(name.substring(9));
        }
        if (lo.startsWith(name, "xf@")) {
            data.displayName = lo.lowerFirst(name.substring(2));
        }

        const desc = {
            configurable: true,
            enumerable:   true,
            writable:     true,
            initializer:  () => null,
        };
        if (info.value != null) {
            desc.initializer = lo.wrap(info.value, value => value);
        }
        if (lo.isArray(info.type)) {
            desc.initializer = () => [];
        }

        Reflect.apply(decorator.property(data), null, [
            prototype,
            name,
            desc,
        ]);
        Reflect.defineMetadata(`xf.property.${name}`, desc, prototype);
    };

    const fx = globalThis.fx = {};

    fx.game = cc.game;

    fx.Component = Component;

    fx.class = function(name, path) {
        return (constructor) => {
            if (path != null) {
                const prototype = constructor.prototype;
                const metadata  = cc.game.bridge.metadata(path);

                metadata.proxy = constructor;

                for (const name of metadata.action) {
                    defineMethod(prototype, name);
                }
                for (const each of metadata.select) {
                    defineProperty(prototype, each.path, each.info);
                }
                for (const each of metadata.property) {
                    defineProperty(prototype, each.path, each.info);
                }
                Reflect.defineMetadata("xf:engine:view", path, prototype);
            }

            Reflect.apply(decorator.class(name), null, [ constructor ]);
        };
    };
})();
