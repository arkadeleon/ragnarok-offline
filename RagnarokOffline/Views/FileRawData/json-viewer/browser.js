/// <reference types="./browser.d.ts" />
(function (global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined' ? module.exports = factory() :
    typeof define === 'function' && define.amd ? define(factory) :
    (global = typeof globalThis !== 'undefined' ? globalThis : global || self, global.JsonViewer = factory());
})(this, (function () { 'use strict';

    function _mergeNamespaces(n, m) {
        m.forEach(function (e) {
            e && typeof e !== 'string' && !Array.isArray(e) && Object.keys(e).forEach(function (k) {
                if (k !== 'default' && !(k in n)) {
                    var d = Object.getOwnPropertyDescriptor(e, k);
                    Object.defineProperty(n, k, d.get ? d : {
                        enumerable: true,
                        get: function () { return e[k]; }
                    });
                }
            });
        });
        return Object.freeze(n);
    }

    function _define_property(obj, key, value) {
        if (key in obj) {
            Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true });
        } else obj[key] = value;

        return obj;
    }

    function getDefaultExportFromCjs (x) {
    	return x && x.__esModule && Object.prototype.hasOwnProperty.call(x, 'default') ? x['default'] : x;
    }

    var jsxRuntime = {exports: {}};

    var reactJsxRuntime_production_min = {};

    var react = {exports: {}};

    var react_production_min = {};

    /**
     * @license React
     * react.production.min.js
     *
     * Copyright (c) Facebook, Inc. and its affiliates.
     *
     * This source code is licensed under the MIT license found in the
     * LICENSE file in the root directory of this source tree.
     */
    var l$3=Symbol.for("react.element"),n$4=Symbol.for("react.portal"),p$5=Symbol.for("react.fragment"),q$4=Symbol.for("react.strict_mode"),r$6=Symbol.for("react.profiler"),t$3=Symbol.for("react.provider"),u$2=Symbol.for("react.context"),v$3=Symbol.for("react.forward_ref"),w$2=Symbol.for("react.suspense"),x$1=Symbol.for("react.memo"),y$1=Symbol.for("react.lazy"),z$2=Symbol.iterator;function A$2(a){if(null===a||"object"!==typeof a)return null;a=z$2&&a[z$2]||a["@@iterator"];return "function"===typeof a?a:null}
    var B$1={isMounted:function(){return !1},enqueueForceUpdate:function(){},enqueueReplaceState:function(){},enqueueSetState:function(){}},C$1=Object.assign,D$1={};function E$1(a,b,e){this.props=a;this.context=b;this.refs=D$1;this.updater=e||B$1;}E$1.prototype.isReactComponent={};
    E$1.prototype.setState=function(a,b){if("object"!==typeof a&&"function"!==typeof a&&null!=a)throw Error("setState(...): takes an object of state variables to update or a function which returns an object of state variables.");this.updater.enqueueSetState(this,a,b,"setState");};E$1.prototype.forceUpdate=function(a){this.updater.enqueueForceUpdate(this,a,"forceUpdate");};function F(){}F.prototype=E$1.prototype;function G$1(a,b,e){this.props=a;this.context=b;this.refs=D$1;this.updater=e||B$1;}var H$1=G$1.prototype=new F;
    H$1.constructor=G$1;C$1(H$1,E$1.prototype);H$1.isPureReactComponent=!0;var I$1=Array.isArray,J=Object.prototype.hasOwnProperty,K$1={current:null},L$1={key:!0,ref:!0,__self:!0,__source:!0};
    function M$1(a,b,e){var d,c={},k=null,h=null;if(null!=b)for(d in void 0!==b.ref&&(h=b.ref),void 0!==b.key&&(k=""+b.key),b)J.call(b,d)&&!L$1.hasOwnProperty(d)&&(c[d]=b[d]);var g=arguments.length-2;if(1===g)c.children=e;else if(1<g){for(var f=Array(g),m=0;m<g;m++)f[m]=arguments[m+2];c.children=f;}if(a&&a.defaultProps)for(d in g=a.defaultProps,g)void 0===c[d]&&(c[d]=g[d]);return {$$typeof:l$3,type:a,key:k,ref:h,props:c,_owner:K$1.current}}
    function N$1(a,b){return {$$typeof:l$3,type:a.type,key:b,ref:a.ref,props:a.props,_owner:a._owner}}function O$1(a){return "object"===typeof a&&null!==a&&a.$$typeof===l$3}function escape(a){var b={"=":"=0",":":"=2"};return "$"+a.replace(/[=:]/g,function(a){return b[a]})}var P$1=/\/+/g;function Q$1(a,b){return "object"===typeof a&&null!==a&&null!=a.key?escape(""+a.key):b.toString(36)}
    function R$1(a,b,e,d,c){var k=typeof a;if("undefined"===k||"boolean"===k)a=null;var h=!1;if(null===a)h=!0;else switch(k){case "string":case "number":h=!0;break;case "object":switch(a.$$typeof){case l$3:case n$4:h=!0;}}if(h)return h=a,c=c(h),a=""===d?"."+Q$1(h,0):d,I$1(c)?(e="",null!=a&&(e=a.replace(P$1,"$&/")+"/"),R$1(c,b,e,"",function(a){return a})):null!=c&&(O$1(c)&&(c=N$1(c,e+(!c.key||h&&h.key===c.key?"":(""+c.key).replace(P$1,"$&/")+"/")+a)),b.push(c)),1;h=0;d=""===d?".":d+":";if(I$1(a))for(var g=0;g<a.length;g++){k=
    a[g];var f=d+Q$1(k,g);h+=R$1(k,b,e,f,c);}else if(f=A$2(a),"function"===typeof f)for(a=f.call(a),g=0;!(k=a.next()).done;)k=k.value,f=d+Q$1(k,g++),h+=R$1(k,b,e,f,c);else if("object"===k)throw b=String(a),Error("Objects are not valid as a React child (found: "+("[object Object]"===b?"object with keys {"+Object.keys(a).join(", ")+"}":b)+"). If you meant to render a collection of children, use an array instead.");return h}
    function S$1(a,b,e){if(null==a)return a;var d=[],c=0;R$1(a,d,"","",function(a){return b.call(e,a,c++)});return d}function T$1(a){if(-1===a._status){var b=a._result;b=b();b.then(function(b){if(0===a._status||-1===a._status)a._status=1,a._result=b;},function(b){if(0===a._status||-1===a._status)a._status=2,a._result=b;});-1===a._status&&(a._status=0,a._result=b);}if(1===a._status)return a._result.default;throw a._result;}
    var U$1={current:null},V$1={transition:null},W$1={ReactCurrentDispatcher:U$1,ReactCurrentBatchConfig:V$1,ReactCurrentOwner:K$1};react_production_min.Children={map:S$1,forEach:function(a,b,e){S$1(a,function(){b.apply(this,arguments);},e);},count:function(a){var b=0;S$1(a,function(){b++;});return b},toArray:function(a){return S$1(a,function(a){return a})||[]},only:function(a){if(!O$1(a))throw Error("React.Children.only expected to receive a single React element child.");return a}};react_production_min.Component=E$1;react_production_min.Fragment=p$5;
    react_production_min.Profiler=r$6;react_production_min.PureComponent=G$1;react_production_min.StrictMode=q$4;react_production_min.Suspense=w$2;react_production_min.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED=W$1;
    react_production_min.cloneElement=function(a,b,e){if(null===a||void 0===a)throw Error("React.cloneElement(...): The argument must be a React element, but you passed "+a+".");var d=C$1({},a.props),c=a.key,k=a.ref,h=a._owner;if(null!=b){void 0!==b.ref&&(k=b.ref,h=K$1.current);void 0!==b.key&&(c=""+b.key);if(a.type&&a.type.defaultProps)var g=a.type.defaultProps;for(f in b)J.call(b,f)&&!L$1.hasOwnProperty(f)&&(d[f]=void 0===b[f]&&void 0!==g?g[f]:b[f]);}var f=arguments.length-2;if(1===f)d.children=e;else if(1<f){g=Array(f);
    for(var m=0;m<f;m++)g[m]=arguments[m+2];d.children=g;}return {$$typeof:l$3,type:a.type,key:c,ref:k,props:d,_owner:h}};react_production_min.createContext=function(a){a={$$typeof:u$2,_currentValue:a,_currentValue2:a,_threadCount:0,Provider:null,Consumer:null,_defaultValue:null,_globalName:null};a.Provider={$$typeof:t$3,_context:a};return a.Consumer=a};react_production_min.createElement=M$1;react_production_min.createFactory=function(a){var b=M$1.bind(null,a);b.type=a;return b};react_production_min.createRef=function(){return {current:null}};
    react_production_min.forwardRef=function(a){return {$$typeof:v$3,render:a}};react_production_min.isValidElement=O$1;react_production_min.lazy=function(a){return {$$typeof:y$1,_payload:{_status:-1,_result:a},_init:T$1}};react_production_min.memo=function(a,b){return {$$typeof:x$1,type:a,compare:void 0===b?null:b}};react_production_min.startTransition=function(a){var b=V$1.transition;V$1.transition={};try{a();}finally{V$1.transition=b;}};react_production_min.unstable_act=function(){throw Error("act(...) is not supported in production builds of React.");};
    react_production_min.useCallback=function(a,b){return U$1.current.useCallback(a,b)};react_production_min.useContext=function(a){return U$1.current.useContext(a)};react_production_min.useDebugValue=function(){};react_production_min.useDeferredValue=function(a){return U$1.current.useDeferredValue(a)};react_production_min.useEffect=function(a,b){return U$1.current.useEffect(a,b)};react_production_min.useId=function(){return U$1.current.useId()};react_production_min.useImperativeHandle=function(a,b,e){return U$1.current.useImperativeHandle(a,b,e)};
    react_production_min.useInsertionEffect=function(a,b){return U$1.current.useInsertionEffect(a,b)};react_production_min.useLayoutEffect=function(a,b){return U$1.current.useLayoutEffect(a,b)};react_production_min.useMemo=function(a,b){return U$1.current.useMemo(a,b)};react_production_min.useReducer=function(a,b,e){return U$1.current.useReducer(a,b,e)};react_production_min.useRef=function(a){return U$1.current.useRef(a)};react_production_min.useState=function(a){return U$1.current.useState(a)};react_production_min.useSyncExternalStore=function(a,b,e){return U$1.current.useSyncExternalStore(a,b,e)};
    react_production_min.useTransition=function(){return U$1.current.useTransition()};react_production_min.version="18.2.0";

    {
      react.exports = react_production_min;
    }

    var reactExports = react.exports;
    var ReactExports = /*@__PURE__*/getDefaultExportFromCjs(reactExports);

    var React = /*#__PURE__*/_mergeNamespaces({
        __proto__: null,
        default: ReactExports
    }, [reactExports]);

    /**
     * @license React
     * react-jsx-runtime.production.min.js
     *
     * Copyright (c) Facebook, Inc. and its affiliates.
     *
     * This source code is licensed under the MIT license found in the
     * LICENSE file in the root directory of this source tree.
     */
    var f$1=reactExports,k$2=Symbol.for("react.element"),l$2=Symbol.for("react.fragment"),m$3=Object.prototype.hasOwnProperty,n$3=f$1.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentOwner,p$4={key:!0,ref:!0,__self:!0,__source:!0};
    function q$3(c,a,g){var b,d={},e=null,h=null;void 0!==g&&(e=""+g);void 0!==a.key&&(e=""+a.key);void 0!==a.ref&&(h=a.ref);for(b in a)m$3.call(a,b)&&!p$4.hasOwnProperty(b)&&(d[b]=a[b]);if(c&&c.defaultProps)for(b in a=c.defaultProps,a)void 0===d[b]&&(d[b]=a[b]);return {$$typeof:k$2,type:c,key:e,ref:h,props:d,_owner:n$3.current}}reactJsxRuntime_production_min.Fragment=l$2;reactJsxRuntime_production_min.jsx=q$3;reactJsxRuntime_production_min.jsxs=q$3;

    {
      jsxRuntime.exports = reactJsxRuntime_production_min;
    }

    var jsxRuntimeExports = jsxRuntime.exports;

    var reactDom = {exports: {}};

    var reactDom_production_min = {};

    var scheduler = {exports: {}};

    var scheduler_production_min = {};

    /**
     * @license React
     * scheduler.production.min.js
     *
     * Copyright (c) Facebook, Inc. and its affiliates.
     *
     * This source code is licensed under the MIT license found in the
     * LICENSE file in the root directory of this source tree.
     */

    (function (exports) {
    function f(a,b){var c=a.length;a.push(b);a:for(;0<c;){var d=c-1>>>1,e=a[d];if(0<g(e,b))a[d]=b,a[c]=e,c=d;else break a}}function h(a){return 0===a.length?null:a[0]}function k(a){if(0===a.length)return null;var b=a[0],c=a.pop();if(c!==b){a[0]=c;a:for(var d=0,e=a.length,w=e>>>1;d<w;){var m=2*(d+1)-1,C=a[m],n=m+1,x=a[n];if(0>g(C,c))n<e&&0>g(x,C)?(a[d]=x,a[n]=c,d=n):(a[d]=C,a[m]=c,d=m);else if(n<e&&0>g(x,c))a[d]=x,a[n]=c,d=n;else break a}}return b}
    	function g(a,b){var c=a.sortIndex-b.sortIndex;return 0!==c?c:a.id-b.id}if("object"===typeof performance&&"function"===typeof performance.now){var l=performance;exports.unstable_now=function(){return l.now()};}else {var p=Date,q=p.now();exports.unstable_now=function(){return p.now()-q};}var r=[],t=[],u=1,v=null,y=3,z=!1,A=!1,B=!1,D="function"===typeof setTimeout?setTimeout:null,E="function"===typeof clearTimeout?clearTimeout:null,F="undefined"!==typeof setImmediate?setImmediate:null;
    	"undefined"!==typeof navigator&&void 0!==navigator.scheduling&&void 0!==navigator.scheduling.isInputPending&&navigator.scheduling.isInputPending.bind(navigator.scheduling);function G(a){for(var b=h(t);null!==b;){if(null===b.callback)k(t);else if(b.startTime<=a)k(t),b.sortIndex=b.expirationTime,f(r,b);else break;b=h(t);}}function H(a){B=!1;G(a);if(!A)if(null!==h(r))A=!0,I(J);else {var b=h(t);null!==b&&K(H,b.startTime-a);}}
    	function J(a,b){A=!1;B&&(B=!1,E(L),L=-1);z=!0;var c=y;try{G(b);for(v=h(r);null!==v&&(!(v.expirationTime>b)||a&&!M());){var d=v.callback;if("function"===typeof d){v.callback=null;y=v.priorityLevel;var e=d(v.expirationTime<=b);b=exports.unstable_now();"function"===typeof e?v.callback=e:v===h(r)&&k(r);G(b);}else k(r);v=h(r);}if(null!==v)var w=!0;else {var m=h(t);null!==m&&K(H,m.startTime-b);w=!1;}return w}finally{v=null,y=c,z=!1;}}var N=!1,O=null,L=-1,P=5,Q=-1;
    	function M(){return exports.unstable_now()-Q<P?!1:!0}function R(){if(null!==O){var a=exports.unstable_now();Q=a;var b=!0;try{b=O(!0,a);}finally{b?S():(N=!1,O=null);}}else N=!1;}var S;if("function"===typeof F)S=function(){F(R);};else if("undefined"!==typeof MessageChannel){var T=new MessageChannel,U=T.port2;T.port1.onmessage=R;S=function(){U.postMessage(null);};}else S=function(){D(R,0);};function I(a){O=a;N||(N=!0,S());}function K(a,b){L=D(function(){a(exports.unstable_now());},b);}
    	exports.unstable_IdlePriority=5;exports.unstable_ImmediatePriority=1;exports.unstable_LowPriority=4;exports.unstable_NormalPriority=3;exports.unstable_Profiling=null;exports.unstable_UserBlockingPriority=2;exports.unstable_cancelCallback=function(a){a.callback=null;};exports.unstable_continueExecution=function(){A||z||(A=!0,I(J));};
    	exports.unstable_forceFrameRate=function(a){0>a||125<a?console.error("forceFrameRate takes a positive int between 0 and 125, forcing frame rates higher than 125 fps is not supported"):P=0<a?Math.floor(1E3/a):5;};exports.unstable_getCurrentPriorityLevel=function(){return y};exports.unstable_getFirstCallbackNode=function(){return h(r)};exports.unstable_next=function(a){switch(y){case 1:case 2:case 3:var b=3;break;default:b=y;}var c=y;y=b;try{return a()}finally{y=c;}};exports.unstable_pauseExecution=function(){};
    	exports.unstable_requestPaint=function(){};exports.unstable_runWithPriority=function(a,b){switch(a){case 1:case 2:case 3:case 4:case 5:break;default:a=3;}var c=y;y=a;try{return b()}finally{y=c;}};
    	exports.unstable_scheduleCallback=function(a,b,c){var d=exports.unstable_now();"object"===typeof c&&null!==c?(c=c.delay,c="number"===typeof c&&0<c?d+c:d):c=d;switch(a){case 1:var e=-1;break;case 2:e=250;break;case 5:e=1073741823;break;case 4:e=1E4;break;default:e=5E3;}e=c+e;a={id:u++,callback:b,priorityLevel:a,startTime:c,expirationTime:e,sortIndex:-1};c>d?(a.sortIndex=c,f(t,a),null===h(r)&&a===h(t)&&(B?(E(L),L=-1):B=!0,K(H,c-d))):(a.sortIndex=e,f(r,a),A||z||(A=!0,I(J)));return a};
    	exports.unstable_shouldYield=M;exports.unstable_wrapCallback=function(a){var b=y;return function(){var c=y;y=b;try{return a.apply(this,arguments)}finally{y=c;}}}; 
    } (scheduler_production_min));

    {
      scheduler.exports = scheduler_production_min;
    }

    var schedulerExports = scheduler.exports;

    /**
     * @license React
     * react-dom.production.min.js
     *
     * Copyright (c) Facebook, Inc. and its affiliates.
     *
     * This source code is licensed under the MIT license found in the
     * LICENSE file in the root directory of this source tree.
     */
    var aa=reactExports,ca=schedulerExports;function p$3(a){for(var b="https://reactjs.org/docs/error-decoder.html?invariant="+a,c=1;c<arguments.length;c++)b+="&args[]="+encodeURIComponent(arguments[c]);return "Minified React error #"+a+"; visit "+b+" for the full message or use the non-minified dev environment for full errors and additional helpful warnings."}var da=new Set,ea={};function fa(a,b){ha(a,b);ha(a+"Capture",b);}
    function ha(a,b){ea[a]=b;for(a=0;a<b.length;a++)da.add(b[a]);}
    var ia=!("undefined"===typeof window.document||"undefined"===typeof window.document.createElement),ja=Object.prototype.hasOwnProperty,ka=/^[:A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD][:A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD\-.0-9\u00B7\u0300-\u036F\u203F-\u2040]*$/,la=
    {},ma={};function oa(a){if(ja.call(ma,a))return !0;if(ja.call(la,a))return !1;if(ka.test(a))return ma[a]=!0;la[a]=!0;return !1}function pa(a,b,c,d){if(null!==c&&0===c.type)return !1;switch(typeof b){case "function":case "symbol":return !0;case "boolean":if(d)return !1;if(null!==c)return !c.acceptsBooleans;a=a.toLowerCase().slice(0,5);return "data-"!==a&&"aria-"!==a;default:return !1}}
    function qa(a,b,c,d){if(null===b||"undefined"===typeof b||pa(a,b,c,d))return !0;if(d)return !1;if(null!==c)switch(c.type){case 3:return !b;case 4:return !1===b;case 5:return isNaN(b);case 6:return isNaN(b)||1>b}return !1}function v$2(a,b,c,d,e,f,g){this.acceptsBooleans=2===b||3===b||4===b;this.attributeName=d;this.attributeNamespace=e;this.mustUseProperty=c;this.propertyName=a;this.type=b;this.sanitizeURL=f;this.removeEmptyString=g;}var z$1={};
    "children dangerouslySetInnerHTML defaultValue defaultChecked innerHTML suppressContentEditableWarning suppressHydrationWarning style".split(" ").forEach(function(a){z$1[a]=new v$2(a,0,!1,a,null,!1,!1);});[["acceptCharset","accept-charset"],["className","class"],["htmlFor","for"],["httpEquiv","http-equiv"]].forEach(function(a){var b=a[0];z$1[b]=new v$2(b,1,!1,a[1],null,!1,!1);});["contentEditable","draggable","spellCheck","value"].forEach(function(a){z$1[a]=new v$2(a,2,!1,a.toLowerCase(),null,!1,!1);});
    ["autoReverse","externalResourcesRequired","focusable","preserveAlpha"].forEach(function(a){z$1[a]=new v$2(a,2,!1,a,null,!1,!1);});"allowFullScreen async autoFocus autoPlay controls default defer disabled disablePictureInPicture disableRemotePlayback formNoValidate hidden loop noModule noValidate open playsInline readOnly required reversed scoped seamless itemScope".split(" ").forEach(function(a){z$1[a]=new v$2(a,3,!1,a.toLowerCase(),null,!1,!1);});
    ["checked","multiple","muted","selected"].forEach(function(a){z$1[a]=new v$2(a,3,!0,a,null,!1,!1);});["capture","download"].forEach(function(a){z$1[a]=new v$2(a,4,!1,a,null,!1,!1);});["cols","rows","size","span"].forEach(function(a){z$1[a]=new v$2(a,6,!1,a,null,!1,!1);});["rowSpan","start"].forEach(function(a){z$1[a]=new v$2(a,5,!1,a.toLowerCase(),null,!1,!1);});var ra=/[\-:]([a-z])/g;function sa(a){return a[1].toUpperCase()}
    "accent-height alignment-baseline arabic-form baseline-shift cap-height clip-path clip-rule color-interpolation color-interpolation-filters color-profile color-rendering dominant-baseline enable-background fill-opacity fill-rule flood-color flood-opacity font-family font-size font-size-adjust font-stretch font-style font-variant font-weight glyph-name glyph-orientation-horizontal glyph-orientation-vertical horiz-adv-x horiz-origin-x image-rendering letter-spacing lighting-color marker-end marker-mid marker-start overline-position overline-thickness paint-order panose-1 pointer-events rendering-intent shape-rendering stop-color stop-opacity strikethrough-position strikethrough-thickness stroke-dasharray stroke-dashoffset stroke-linecap stroke-linejoin stroke-miterlimit stroke-opacity stroke-width text-anchor text-decoration text-rendering underline-position underline-thickness unicode-bidi unicode-range units-per-em v-alphabetic v-hanging v-ideographic v-mathematical vector-effect vert-adv-y vert-origin-x vert-origin-y word-spacing writing-mode xmlns:xlink x-height".split(" ").forEach(function(a){var b=a.replace(ra,
    sa);z$1[b]=new v$2(b,1,!1,a,null,!1,!1);});"xlink:actuate xlink:arcrole xlink:role xlink:show xlink:title xlink:type".split(" ").forEach(function(a){var b=a.replace(ra,sa);z$1[b]=new v$2(b,1,!1,a,"http://www.w3.org/1999/xlink",!1,!1);});["xml:base","xml:lang","xml:space"].forEach(function(a){var b=a.replace(ra,sa);z$1[b]=new v$2(b,1,!1,a,"http://www.w3.org/XML/1998/namespace",!1,!1);});["tabIndex","crossOrigin"].forEach(function(a){z$1[a]=new v$2(a,1,!1,a.toLowerCase(),null,!1,!1);});
    z$1.xlinkHref=new v$2("xlinkHref",1,!1,"xlink:href","http://www.w3.org/1999/xlink",!0,!1);["src","href","action","formAction"].forEach(function(a){z$1[a]=new v$2(a,1,!1,a.toLowerCase(),null,!0,!0);});
    function ta(a,b,c,d){var e=z$1.hasOwnProperty(b)?z$1[b]:null;if(null!==e?0!==e.type:d||!(2<b.length)||"o"!==b[0]&&"O"!==b[0]||"n"!==b[1]&&"N"!==b[1])qa(b,c,e,d)&&(c=null),d||null===e?oa(b)&&(null===c?a.removeAttribute(b):a.setAttribute(b,""+c)):e.mustUseProperty?a[e.propertyName]=null===c?3===e.type?!1:"":c:(b=e.attributeName,d=e.attributeNamespace,null===c?a.removeAttribute(b):(e=e.type,c=3===e||4===e&&!0===c?"":""+c,d?a.setAttributeNS(d,b,c):a.setAttribute(b,c)));}
    var ua=aa.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED,va=Symbol.for("react.element"),wa=Symbol.for("react.portal"),ya=Symbol.for("react.fragment"),za=Symbol.for("react.strict_mode"),Aa=Symbol.for("react.profiler"),Ba=Symbol.for("react.provider"),Ca=Symbol.for("react.context"),Da=Symbol.for("react.forward_ref"),Ea=Symbol.for("react.suspense"),Fa=Symbol.for("react.suspense_list"),Ga=Symbol.for("react.memo"),Ha=Symbol.for("react.lazy");var Ia=Symbol.for("react.offscreen");var Ja=Symbol.iterator;function Ka(a){if(null===a||"object"!==typeof a)return null;a=Ja&&a[Ja]||a["@@iterator"];return "function"===typeof a?a:null}var A$1=Object.assign,La;function Ma(a){if(void 0===La)try{throw Error();}catch(c){var b=c.stack.trim().match(/\n( *(at )?)/);La=b&&b[1]||"";}return "\n"+La+a}var Na=!1;
    function Oa(a,b){if(!a||Na)return "";Na=!0;var c=Error.prepareStackTrace;Error.prepareStackTrace=void 0;try{if(b)if(b=function(){throw Error();},Object.defineProperty(b.prototype,"props",{set:function(){throw Error();}}),"object"===typeof Reflect&&Reflect.construct){try{Reflect.construct(b,[]);}catch(l){var d=l;}Reflect.construct(a,[],b);}else {try{b.call();}catch(l){d=l;}a.call(b.prototype);}else {try{throw Error();}catch(l){d=l;}a();}}catch(l){if(l&&d&&"string"===typeof l.stack){for(var e=l.stack.split("\n"),
    f=d.stack.split("\n"),g=e.length-1,h=f.length-1;1<=g&&0<=h&&e[g]!==f[h];)h--;for(;1<=g&&0<=h;g--,h--)if(e[g]!==f[h]){if(1!==g||1!==h){do if(g--,h--,0>h||e[g]!==f[h]){var k="\n"+e[g].replace(" at new "," at ");a.displayName&&k.includes("<anonymous>")&&(k=k.replace("<anonymous>",a.displayName));return k}while(1<=g&&0<=h)}break}}}finally{Na=!1,Error.prepareStackTrace=c;}return (a=a?a.displayName||a.name:"")?Ma(a):""}
    function Pa(a){switch(a.tag){case 5:return Ma(a.type);case 16:return Ma("Lazy");case 13:return Ma("Suspense");case 19:return Ma("SuspenseList");case 0:case 2:case 15:return a=Oa(a.type,!1),a;case 11:return a=Oa(a.type.render,!1),a;case 1:return a=Oa(a.type,!0),a;default:return ""}}
    function Qa(a){if(null==a)return null;if("function"===typeof a)return a.displayName||a.name||null;if("string"===typeof a)return a;switch(a){case ya:return "Fragment";case wa:return "Portal";case Aa:return "Profiler";case za:return "StrictMode";case Ea:return "Suspense";case Fa:return "SuspenseList"}if("object"===typeof a)switch(a.$$typeof){case Ca:return (a.displayName||"Context")+".Consumer";case Ba:return (a._context.displayName||"Context")+".Provider";case Da:var b=a.render;a=a.displayName;a||(a=b.displayName||
    b.name||"",a=""!==a?"ForwardRef("+a+")":"ForwardRef");return a;case Ga:return b=a.displayName||null,null!==b?b:Qa(a.type)||"Memo";case Ha:b=a._payload;a=a._init;try{return Qa(a(b))}catch(c){}}return null}
    function Ra(a){var b=a.type;switch(a.tag){case 24:return "Cache";case 9:return (b.displayName||"Context")+".Consumer";case 10:return (b._context.displayName||"Context")+".Provider";case 18:return "DehydratedFragment";case 11:return a=b.render,a=a.displayName||a.name||"",b.displayName||(""!==a?"ForwardRef("+a+")":"ForwardRef");case 7:return "Fragment";case 5:return b;case 4:return "Portal";case 3:return "Root";case 6:return "Text";case 16:return Qa(b);case 8:return b===za?"StrictMode":"Mode";case 22:return "Offscreen";
    case 12:return "Profiler";case 21:return "Scope";case 13:return "Suspense";case 19:return "SuspenseList";case 25:return "TracingMarker";case 1:case 0:case 17:case 2:case 14:case 15:if("function"===typeof b)return b.displayName||b.name||null;if("string"===typeof b)return b}return null}function Sa(a){switch(typeof a){case "boolean":case "number":case "string":case "undefined":return a;case "object":return a;default:return ""}}
    function Ta(a){var b=a.type;return (a=a.nodeName)&&"input"===a.toLowerCase()&&("checkbox"===b||"radio"===b)}
    function Ua(a){var b=Ta(a)?"checked":"value",c=Object.getOwnPropertyDescriptor(a.constructor.prototype,b),d=""+a[b];if(!a.hasOwnProperty(b)&&"undefined"!==typeof c&&"function"===typeof c.get&&"function"===typeof c.set){var e=c.get,f=c.set;Object.defineProperty(a,b,{configurable:!0,get:function(){return e.call(this)},set:function(a){d=""+a;f.call(this,a);}});Object.defineProperty(a,b,{enumerable:c.enumerable});return {getValue:function(){return d},setValue:function(a){d=""+a;},stopTracking:function(){a._valueTracker=
    null;delete a[b];}}}}function Va(a){a._valueTracker||(a._valueTracker=Ua(a));}function Wa(a){if(!a)return !1;var b=a._valueTracker;if(!b)return !0;var c=b.getValue();var d="";a&&(d=Ta(a)?a.checked?"true":"false":a.value);a=d;return a!==c?(b.setValue(a),!0):!1}function Xa(a){a=a||("undefined"!==typeof document?document:void 0);if("undefined"===typeof a)return null;try{return a.activeElement||a.body}catch(b){return a.body}}
    function Ya(a,b){var c=b.checked;return A$1({},b,{defaultChecked:void 0,defaultValue:void 0,value:void 0,checked:null!=c?c:a._wrapperState.initialChecked})}function Za(a,b){var c=null==b.defaultValue?"":b.defaultValue,d=null!=b.checked?b.checked:b.defaultChecked;c=Sa(null!=b.value?b.value:c);a._wrapperState={initialChecked:d,initialValue:c,controlled:"checkbox"===b.type||"radio"===b.type?null!=b.checked:null!=b.value};}function ab(a,b){b=b.checked;null!=b&&ta(a,"checked",b,!1);}
    function bb(a,b){ab(a,b);var c=Sa(b.value),d=b.type;if(null!=c)if("number"===d){if(0===c&&""===a.value||a.value!=c)a.value=""+c;}else a.value!==""+c&&(a.value=""+c);else if("submit"===d||"reset"===d){a.removeAttribute("value");return}b.hasOwnProperty("value")?cb(a,b.type,c):b.hasOwnProperty("defaultValue")&&cb(a,b.type,Sa(b.defaultValue));null==b.checked&&null!=b.defaultChecked&&(a.defaultChecked=!!b.defaultChecked);}
    function db(a,b,c){if(b.hasOwnProperty("value")||b.hasOwnProperty("defaultValue")){var d=b.type;if(!("submit"!==d&&"reset"!==d||void 0!==b.value&&null!==b.value))return;b=""+a._wrapperState.initialValue;c||b===a.value||(a.value=b);a.defaultValue=b;}c=a.name;""!==c&&(a.name="");a.defaultChecked=!!a._wrapperState.initialChecked;""!==c&&(a.name=c);}
    function cb(a,b,c){if("number"!==b||Xa(a.ownerDocument)!==a)null==c?a.defaultValue=""+a._wrapperState.initialValue:a.defaultValue!==""+c&&(a.defaultValue=""+c);}var eb=Array.isArray;
    function fb(a,b,c,d){a=a.options;if(b){b={};for(var e=0;e<c.length;e++)b["$"+c[e]]=!0;for(c=0;c<a.length;c++)e=b.hasOwnProperty("$"+a[c].value),a[c].selected!==e&&(a[c].selected=e),e&&d&&(a[c].defaultSelected=!0);}else {c=""+Sa(c);b=null;for(e=0;e<a.length;e++){if(a[e].value===c){a[e].selected=!0;d&&(a[e].defaultSelected=!0);return}null!==b||a[e].disabled||(b=a[e]);}null!==b&&(b.selected=!0);}}
    function gb(a,b){if(null!=b.dangerouslySetInnerHTML)throw Error(p$3(91));return A$1({},b,{value:void 0,defaultValue:void 0,children:""+a._wrapperState.initialValue})}function hb(a,b){var c=b.value;if(null==c){c=b.children;b=b.defaultValue;if(null!=c){if(null!=b)throw Error(p$3(92));if(eb(c)){if(1<c.length)throw Error(p$3(93));c=c[0];}b=c;}null==b&&(b="");c=b;}a._wrapperState={initialValue:Sa(c)};}
    function ib(a,b){var c=Sa(b.value),d=Sa(b.defaultValue);null!=c&&(c=""+c,c!==a.value&&(a.value=c),null==b.defaultValue&&a.defaultValue!==c&&(a.defaultValue=c));null!=d&&(a.defaultValue=""+d);}function jb(a){var b=a.textContent;b===a._wrapperState.initialValue&&""!==b&&null!==b&&(a.value=b);}function kb(a){switch(a){case "svg":return "http://www.w3.org/2000/svg";case "math":return "http://www.w3.org/1998/Math/MathML";default:return "http://www.w3.org/1999/xhtml"}}
    function lb$1(a,b){return null==a||"http://www.w3.org/1999/xhtml"===a?kb(b):"http://www.w3.org/2000/svg"===a&&"foreignObject"===b?"http://www.w3.org/1999/xhtml":a}
    var mb,nb=function(a){return "undefined"!==typeof MSApp&&MSApp.execUnsafeLocalFunction?function(b,c,d,e){MSApp.execUnsafeLocalFunction(function(){return a(b,c,d,e)});}:a}(function(a,b){if("http://www.w3.org/2000/svg"!==a.namespaceURI||"innerHTML"in a)a.innerHTML=b;else {mb=mb||document.createElement("div");mb.innerHTML="<svg>"+b.valueOf().toString()+"</svg>";for(b=mb.firstChild;a.firstChild;)a.removeChild(a.firstChild);for(;b.firstChild;)a.appendChild(b.firstChild);}});
    function ob(a,b){if(b){var c=a.firstChild;if(c&&c===a.lastChild&&3===c.nodeType){c.nodeValue=b;return}}a.textContent=b;}
    var pb={animationIterationCount:!0,aspectRatio:!0,borderImageOutset:!0,borderImageSlice:!0,borderImageWidth:!0,boxFlex:!0,boxFlexGroup:!0,boxOrdinalGroup:!0,columnCount:!0,columns:!0,flex:!0,flexGrow:!0,flexPositive:!0,flexShrink:!0,flexNegative:!0,flexOrder:!0,gridArea:!0,gridRow:!0,gridRowEnd:!0,gridRowSpan:!0,gridRowStart:!0,gridColumn:!0,gridColumnEnd:!0,gridColumnSpan:!0,gridColumnStart:!0,fontWeight:!0,lineClamp:!0,lineHeight:!0,opacity:!0,order:!0,orphans:!0,tabSize:!0,widows:!0,zIndex:!0,
    zoom:!0,fillOpacity:!0,floodOpacity:!0,stopOpacity:!0,strokeDasharray:!0,strokeDashoffset:!0,strokeMiterlimit:!0,strokeOpacity:!0,strokeWidth:!0},qb=["Webkit","ms","Moz","O"];Object.keys(pb).forEach(function(a){qb.forEach(function(b){b=b+a.charAt(0).toUpperCase()+a.substring(1);pb[b]=pb[a];});});function rb$1(a,b,c){return null==b||"boolean"===typeof b||""===b?"":c||"number"!==typeof b||0===b||pb.hasOwnProperty(a)&&pb[a]?(""+b).trim():b+"px"}
    function sb(a,b){a=a.style;for(var c in b)if(b.hasOwnProperty(c)){var d=0===c.indexOf("--"),e=rb$1(c,b[c],d);"float"===c&&(c="cssFloat");d?a.setProperty(c,e):a[c]=e;}}var tb=A$1({menuitem:!0},{area:!0,base:!0,br:!0,col:!0,embed:!0,hr:!0,img:!0,input:!0,keygen:!0,link:!0,meta:!0,param:!0,source:!0,track:!0,wbr:!0});
    function ub(a,b){if(b){if(tb[a]&&(null!=b.children||null!=b.dangerouslySetInnerHTML))throw Error(p$3(137,a));if(null!=b.dangerouslySetInnerHTML){if(null!=b.children)throw Error(p$3(60));if("object"!==typeof b.dangerouslySetInnerHTML||!("__html"in b.dangerouslySetInnerHTML))throw Error(p$3(61));}if(null!=b.style&&"object"!==typeof b.style)throw Error(p$3(62));}}
    function vb(a,b){if(-1===a.indexOf("-"))return "string"===typeof b.is;switch(a){case "annotation-xml":case "color-profile":case "font-face":case "font-face-src":case "font-face-uri":case "font-face-format":case "font-face-name":case "missing-glyph":return !1;default:return !0}}var wb=null;function xb(a){a=a.target||a.srcElement||window;a.correspondingUseElement&&(a=a.correspondingUseElement);return 3===a.nodeType?a.parentNode:a}var yb=null,zb=null,Ab=null;
    function Bb(a){if(a=Cb(a)){if("function"!==typeof yb)throw Error(p$3(280));var b=a.stateNode;b&&(b=Db(b),yb(a.stateNode,a.type,b));}}function Eb(a){zb?Ab?Ab.push(a):Ab=[a]:zb=a;}function Fb(){if(zb){var a=zb,b=Ab;Ab=zb=null;Bb(a);if(b)for(a=0;a<b.length;a++)Bb(b[a]);}}function Gb(a,b){return a(b)}function Hb(){}var Ib=!1;function Jb(a,b,c){if(Ib)return a(b,c);Ib=!0;try{return Gb(a,b,c)}finally{if(Ib=!1,null!==zb||null!==Ab)Hb(),Fb();}}
    function Kb(a,b){var c=a.stateNode;if(null===c)return null;var d=Db(c);if(null===d)return null;c=d[b];a:switch(b){case "onClick":case "onClickCapture":case "onDoubleClick":case "onDoubleClickCapture":case "onMouseDown":case "onMouseDownCapture":case "onMouseMove":case "onMouseMoveCapture":case "onMouseUp":case "onMouseUpCapture":case "onMouseEnter":(d=!d.disabled)||(a=a.type,d=!("button"===a||"input"===a||"select"===a||"textarea"===a));a=!d;break a;default:a=!1;}if(a)return null;if(c&&"function"!==
    typeof c)throw Error(p$3(231,b,typeof c));return c}var Lb=!1;if(ia)try{var Mb={};Object.defineProperty(Mb,"passive",{get:function(){Lb=!0;}});window.addEventListener("test",Mb,Mb);window.removeEventListener("test",Mb,Mb);}catch(a){Lb=!1;}function Nb(a,b,c,d,e,f,g,h,k){var l=Array.prototype.slice.call(arguments,3);try{b.apply(c,l);}catch(m){this.onError(m);}}var Ob=!1,Pb=null,Qb=!1,Rb=null,Sb={onError:function(a){Ob=!0;Pb=a;}};function Tb(a,b,c,d,e,f,g,h,k){Ob=!1;Pb=null;Nb.apply(Sb,arguments);}
    function Ub(a,b,c,d,e,f,g,h,k){Tb.apply(this,arguments);if(Ob){if(Ob){var l=Pb;Ob=!1;Pb=null;}else throw Error(p$3(198));Qb||(Qb=!0,Rb=l);}}function Vb(a){var b=a,c=a;if(a.alternate)for(;b.return;)b=b.return;else {a=b;do b=a,0!==(b.flags&4098)&&(c=b.return),a=b.return;while(a)}return 3===b.tag?c:null}function Wb(a){if(13===a.tag){var b=a.memoizedState;null===b&&(a=a.alternate,null!==a&&(b=a.memoizedState));if(null!==b)return b.dehydrated}return null}function Xb(a){if(Vb(a)!==a)throw Error(p$3(188));}
    function Yb(a){var b=a.alternate;if(!b){b=Vb(a);if(null===b)throw Error(p$3(188));return b!==a?null:a}for(var c=a,d=b;;){var e=c.return;if(null===e)break;var f=e.alternate;if(null===f){d=e.return;if(null!==d){c=d;continue}break}if(e.child===f.child){for(f=e.child;f;){if(f===c)return Xb(e),a;if(f===d)return Xb(e),b;f=f.sibling;}throw Error(p$3(188));}if(c.return!==d.return)c=e,d=f;else {for(var g=!1,h=e.child;h;){if(h===c){g=!0;c=e;d=f;break}if(h===d){g=!0;d=e;c=f;break}h=h.sibling;}if(!g){for(h=f.child;h;){if(h===
    c){g=!0;c=f;d=e;break}if(h===d){g=!0;d=f;c=e;break}h=h.sibling;}if(!g)throw Error(p$3(189));}}if(c.alternate!==d)throw Error(p$3(190));}if(3!==c.tag)throw Error(p$3(188));return c.stateNode.current===c?a:b}function Zb(a){a=Yb(a);return null!==a?$b(a):null}function $b(a){if(5===a.tag||6===a.tag)return a;for(a=a.child;null!==a;){var b=$b(a);if(null!==b)return b;a=a.sibling;}return null}
    var ac=ca.unstable_scheduleCallback,bc=ca.unstable_cancelCallback,cc=ca.unstable_shouldYield,dc=ca.unstable_requestPaint,B=ca.unstable_now,ec=ca.unstable_getCurrentPriorityLevel,fc=ca.unstable_ImmediatePriority,gc=ca.unstable_UserBlockingPriority,hc=ca.unstable_NormalPriority,ic=ca.unstable_LowPriority,jc=ca.unstable_IdlePriority,kc=null,lc=null;function mc(a){if(lc&&"function"===typeof lc.onCommitFiberRoot)try{lc.onCommitFiberRoot(kc,a,void 0,128===(a.current.flags&128));}catch(b){}}
    var oc=Math.clz32?Math.clz32:nc,pc=Math.log,qc=Math.LN2;function nc(a){a>>>=0;return 0===a?32:31-(pc(a)/qc|0)|0}var rc=64,sc=4194304;
    function tc(a){switch(a&-a){case 1:return 1;case 2:return 2;case 4:return 4;case 8:return 8;case 16:return 16;case 32:return 32;case 64:case 128:case 256:case 512:case 1024:case 2048:case 4096:case 8192:case 16384:case 32768:case 65536:case 131072:case 262144:case 524288:case 1048576:case 2097152:return a&4194240;case 4194304:case 8388608:case 16777216:case 33554432:case 67108864:return a&130023424;case 134217728:return 134217728;case 268435456:return 268435456;case 536870912:return 536870912;case 1073741824:return 1073741824;
    default:return a}}function uc(a,b){var c=a.pendingLanes;if(0===c)return 0;var d=0,e=a.suspendedLanes,f=a.pingedLanes,g=c&268435455;if(0!==g){var h=g&~e;0!==h?d=tc(h):(f&=g,0!==f&&(d=tc(f)));}else g=c&~e,0!==g?d=tc(g):0!==f&&(d=tc(f));if(0===d)return 0;if(0!==b&&b!==d&&0===(b&e)&&(e=d&-d,f=b&-b,e>=f||16===e&&0!==(f&4194240)))return b;0!==(d&4)&&(d|=c&16);b=a.entangledLanes;if(0!==b)for(a=a.entanglements,b&=d;0<b;)c=31-oc(b),e=1<<c,d|=a[c],b&=~e;return d}
    function vc(a,b){switch(a){case 1:case 2:case 4:return b+250;case 8:case 16:case 32:case 64:case 128:case 256:case 512:case 1024:case 2048:case 4096:case 8192:case 16384:case 32768:case 65536:case 131072:case 262144:case 524288:case 1048576:case 2097152:return b+5E3;case 4194304:case 8388608:case 16777216:case 33554432:case 67108864:return -1;case 134217728:case 268435456:case 536870912:case 1073741824:return -1;default:return -1}}
    function wc(a,b){for(var c=a.suspendedLanes,d=a.pingedLanes,e=a.expirationTimes,f=a.pendingLanes;0<f;){var g=31-oc(f),h=1<<g,k=e[g];if(-1===k){if(0===(h&c)||0!==(h&d))e[g]=vc(h,b);}else k<=b&&(a.expiredLanes|=h);f&=~h;}}function xc(a){a=a.pendingLanes&-1073741825;return 0!==a?a:a&1073741824?1073741824:0}function yc(){var a=rc;rc<<=1;0===(rc&4194240)&&(rc=64);return a}function zc(a){for(var b=[],c=0;31>c;c++)b.push(a);return b}
    function Ac(a,b,c){a.pendingLanes|=b;536870912!==b&&(a.suspendedLanes=0,a.pingedLanes=0);a=a.eventTimes;b=31-oc(b);a[b]=c;}function Bc(a,b){var c=a.pendingLanes&~b;a.pendingLanes=b;a.suspendedLanes=0;a.pingedLanes=0;a.expiredLanes&=b;a.mutableReadLanes&=b;a.entangledLanes&=b;b=a.entanglements;var d=a.eventTimes;for(a=a.expirationTimes;0<c;){var e=31-oc(c),f=1<<e;b[e]=0;d[e]=-1;a[e]=-1;c&=~f;}}
    function Cc(a,b){var c=a.entangledLanes|=b;for(a=a.entanglements;c;){var d=31-oc(c),e=1<<d;e&b|a[d]&b&&(a[d]|=b);c&=~e;}}var C=0;function Dc(a){a&=-a;return 1<a?4<a?0!==(a&268435455)?16:536870912:4:1}var Ec,Fc,Gc,Hc,Ic,Jc=!1,Kc=[],Lc=null,Mc=null,Nc=null,Oc=new Map,Pc=new Map,Qc=[],Rc="mousedown mouseup touchcancel touchend touchstart auxclick dblclick pointercancel pointerdown pointerup dragend dragstart drop compositionend compositionstart keydown keypress keyup input textInput copy cut paste click change contextmenu reset submit".split(" ");
    function Sc(a,b){switch(a){case "focusin":case "focusout":Lc=null;break;case "dragenter":case "dragleave":Mc=null;break;case "mouseover":case "mouseout":Nc=null;break;case "pointerover":case "pointerout":Oc.delete(b.pointerId);break;case "gotpointercapture":case "lostpointercapture":Pc.delete(b.pointerId);}}
    function Tc(a,b,c,d,e,f){if(null===a||a.nativeEvent!==f)return a={blockedOn:b,domEventName:c,eventSystemFlags:d,nativeEvent:f,targetContainers:[e]},null!==b&&(b=Cb(b),null!==b&&Fc(b)),a;a.eventSystemFlags|=d;b=a.targetContainers;null!==e&&-1===b.indexOf(e)&&b.push(e);return a}
    function Uc(a,b,c,d,e){switch(b){case "focusin":return Lc=Tc(Lc,a,b,c,d,e),!0;case "dragenter":return Mc=Tc(Mc,a,b,c,d,e),!0;case "mouseover":return Nc=Tc(Nc,a,b,c,d,e),!0;case "pointerover":var f=e.pointerId;Oc.set(f,Tc(Oc.get(f)||null,a,b,c,d,e));return !0;case "gotpointercapture":return f=e.pointerId,Pc.set(f,Tc(Pc.get(f)||null,a,b,c,d,e)),!0}return !1}
    function Vc(a){var b=Wc(a.target);if(null!==b){var c=Vb(b);if(null!==c)if(b=c.tag,13===b){if(b=Wb(c),null!==b){a.blockedOn=b;Ic(a.priority,function(){Gc(c);});return}}else if(3===b&&c.stateNode.current.memoizedState.isDehydrated){a.blockedOn=3===c.tag?c.stateNode.containerInfo:null;return}}a.blockedOn=null;}
    function Xc(a){if(null!==a.blockedOn)return !1;for(var b=a.targetContainers;0<b.length;){var c=Yc(a.domEventName,a.eventSystemFlags,b[0],a.nativeEvent);if(null===c){c=a.nativeEvent;var d=new c.constructor(c.type,c);wb=d;c.target.dispatchEvent(d);wb=null;}else return b=Cb(c),null!==b&&Fc(b),a.blockedOn=c,!1;b.shift();}return !0}function Zc(a,b,c){Xc(a)&&c.delete(b);}function $c(){Jc=!1;null!==Lc&&Xc(Lc)&&(Lc=null);null!==Mc&&Xc(Mc)&&(Mc=null);null!==Nc&&Xc(Nc)&&(Nc=null);Oc.forEach(Zc);Pc.forEach(Zc);}
    function ad(a,b){a.blockedOn===b&&(a.blockedOn=null,Jc||(Jc=!0,ca.unstable_scheduleCallback(ca.unstable_NormalPriority,$c)));}
    function bd(a){function b(b){return ad(b,a)}if(0<Kc.length){ad(Kc[0],a);for(var c=1;c<Kc.length;c++){var d=Kc[c];d.blockedOn===a&&(d.blockedOn=null);}}null!==Lc&&ad(Lc,a);null!==Mc&&ad(Mc,a);null!==Nc&&ad(Nc,a);Oc.forEach(b);Pc.forEach(b);for(c=0;c<Qc.length;c++)d=Qc[c],d.blockedOn===a&&(d.blockedOn=null);for(;0<Qc.length&&(c=Qc[0],null===c.blockedOn);)Vc(c),null===c.blockedOn&&Qc.shift();}var cd=ua.ReactCurrentBatchConfig,dd=!0;
    function ed(a,b,c,d){var e=C,f=cd.transition;cd.transition=null;try{C=1,fd(a,b,c,d);}finally{C=e,cd.transition=f;}}function gd(a,b,c,d){var e=C,f=cd.transition;cd.transition=null;try{C=4,fd(a,b,c,d);}finally{C=e,cd.transition=f;}}
    function fd(a,b,c,d){if(dd){var e=Yc(a,b,c,d);if(null===e)hd(a,b,d,id,c),Sc(a,d);else if(Uc(e,a,b,c,d))d.stopPropagation();else if(Sc(a,d),b&4&&-1<Rc.indexOf(a)){for(;null!==e;){var f=Cb(e);null!==f&&Ec(f);f=Yc(a,b,c,d);null===f&&hd(a,b,d,id,c);if(f===e)break;e=f;}null!==e&&d.stopPropagation();}else hd(a,b,d,null,c);}}var id=null;
    function Yc(a,b,c,d){id=null;a=xb(d);a=Wc(a);if(null!==a)if(b=Vb(a),null===b)a=null;else if(c=b.tag,13===c){a=Wb(b);if(null!==a)return a;a=null;}else if(3===c){if(b.stateNode.current.memoizedState.isDehydrated)return 3===b.tag?b.stateNode.containerInfo:null;a=null;}else b!==a&&(a=null);id=a;return null}
    function jd(a){switch(a){case "cancel":case "click":case "close":case "contextmenu":case "copy":case "cut":case "auxclick":case "dblclick":case "dragend":case "dragstart":case "drop":case "focusin":case "focusout":case "input":case "invalid":case "keydown":case "keypress":case "keyup":case "mousedown":case "mouseup":case "paste":case "pause":case "play":case "pointercancel":case "pointerdown":case "pointerup":case "ratechange":case "reset":case "resize":case "seeked":case "submit":case "touchcancel":case "touchend":case "touchstart":case "volumechange":case "change":case "selectionchange":case "textInput":case "compositionstart":case "compositionend":case "compositionupdate":case "beforeblur":case "afterblur":case "beforeinput":case "blur":case "fullscreenchange":case "focus":case "hashchange":case "popstate":case "select":case "selectstart":return 1;case "drag":case "dragenter":case "dragexit":case "dragleave":case "dragover":case "mousemove":case "mouseout":case "mouseover":case "pointermove":case "pointerout":case "pointerover":case "scroll":case "toggle":case "touchmove":case "wheel":case "mouseenter":case "mouseleave":case "pointerenter":case "pointerleave":return 4;
    case "message":switch(ec()){case fc:return 1;case gc:return 4;case hc:case ic:return 16;case jc:return 536870912;default:return 16}default:return 16}}var kd=null,ld=null,md=null;function nd(){if(md)return md;var a,b=ld,c=b.length,d,e="value"in kd?kd.value:kd.textContent,f=e.length;for(a=0;a<c&&b[a]===e[a];a++);var g=c-a;for(d=1;d<=g&&b[c-d]===e[f-d];d++);return md=e.slice(a,1<d?1-d:void 0)}
    function od(a){var b=a.keyCode;"charCode"in a?(a=a.charCode,0===a&&13===b&&(a=13)):a=b;10===a&&(a=13);return 32<=a||13===a?a:0}function pd(){return !0}function qd(){return !1}
    function rd(a){function b(b,d,e,f,g){this._reactName=b;this._targetInst=e;this.type=d;this.nativeEvent=f;this.target=g;this.currentTarget=null;for(var c in a)a.hasOwnProperty(c)&&(b=a[c],this[c]=b?b(f):f[c]);this.isDefaultPrevented=(null!=f.defaultPrevented?f.defaultPrevented:!1===f.returnValue)?pd:qd;this.isPropagationStopped=qd;return this}A$1(b.prototype,{preventDefault:function(){this.defaultPrevented=!0;var a=this.nativeEvent;a&&(a.preventDefault?a.preventDefault():"unknown"!==typeof a.returnValue&&
    (a.returnValue=!1),this.isDefaultPrevented=pd);},stopPropagation:function(){var a=this.nativeEvent;a&&(a.stopPropagation?a.stopPropagation():"unknown"!==typeof a.cancelBubble&&(a.cancelBubble=!0),this.isPropagationStopped=pd);},persist:function(){},isPersistent:pd});return b}
    var sd={eventPhase:0,bubbles:0,cancelable:0,timeStamp:function(a){return a.timeStamp||Date.now()},defaultPrevented:0,isTrusted:0},td=rd(sd),ud=A$1({},sd,{view:0,detail:0}),vd=rd(ud),wd,xd,yd,Ad=A$1({},ud,{screenX:0,screenY:0,clientX:0,clientY:0,pageX:0,pageY:0,ctrlKey:0,shiftKey:0,altKey:0,metaKey:0,getModifierState:zd,button:0,buttons:0,relatedTarget:function(a){return void 0===a.relatedTarget?a.fromElement===a.srcElement?a.toElement:a.fromElement:a.relatedTarget},movementX:function(a){if("movementX"in
    a)return a.movementX;a!==yd&&(yd&&"mousemove"===a.type?(wd=a.screenX-yd.screenX,xd=a.screenY-yd.screenY):xd=wd=0,yd=a);return wd},movementY:function(a){return "movementY"in a?a.movementY:xd}}),Bd=rd(Ad),Cd=A$1({},Ad,{dataTransfer:0}),Dd=rd(Cd),Ed=A$1({},ud,{relatedTarget:0}),Fd=rd(Ed),Gd=A$1({},sd,{animationName:0,elapsedTime:0,pseudoElement:0}),Hd=rd(Gd),Id=A$1({},sd,{clipboardData:function(a){return "clipboardData"in a?a.clipboardData:window.clipboardData}}),Jd=rd(Id),Kd=A$1({},sd,{data:0}),Ld=rd(Kd),Md={Esc:"Escape",
    Spacebar:" ",Left:"ArrowLeft",Up:"ArrowUp",Right:"ArrowRight",Down:"ArrowDown",Del:"Delete",Win:"OS",Menu:"ContextMenu",Apps:"ContextMenu",Scroll:"ScrollLock",MozPrintableKey:"Unidentified"},Nd={8:"Backspace",9:"Tab",12:"Clear",13:"Enter",16:"Shift",17:"Control",18:"Alt",19:"Pause",20:"CapsLock",27:"Escape",32:" ",33:"PageUp",34:"PageDown",35:"End",36:"Home",37:"ArrowLeft",38:"ArrowUp",39:"ArrowRight",40:"ArrowDown",45:"Insert",46:"Delete",112:"F1",113:"F2",114:"F3",115:"F4",116:"F5",117:"F6",118:"F7",
    119:"F8",120:"F9",121:"F10",122:"F11",123:"F12",144:"NumLock",145:"ScrollLock",224:"Meta"},Od={Alt:"altKey",Control:"ctrlKey",Meta:"metaKey",Shift:"shiftKey"};function Pd(a){var b=this.nativeEvent;return b.getModifierState?b.getModifierState(a):(a=Od[a])?!!b[a]:!1}function zd(){return Pd}
    var Qd=A$1({},ud,{key:function(a){if(a.key){var b=Md[a.key]||a.key;if("Unidentified"!==b)return b}return "keypress"===a.type?(a=od(a),13===a?"Enter":String.fromCharCode(a)):"keydown"===a.type||"keyup"===a.type?Nd[a.keyCode]||"Unidentified":""},code:0,location:0,ctrlKey:0,shiftKey:0,altKey:0,metaKey:0,repeat:0,locale:0,getModifierState:zd,charCode:function(a){return "keypress"===a.type?od(a):0},keyCode:function(a){return "keydown"===a.type||"keyup"===a.type?a.keyCode:0},which:function(a){return "keypress"===
    a.type?od(a):"keydown"===a.type||"keyup"===a.type?a.keyCode:0}}),Rd=rd(Qd),Sd=A$1({},Ad,{pointerId:0,width:0,height:0,pressure:0,tangentialPressure:0,tiltX:0,tiltY:0,twist:0,pointerType:0,isPrimary:0}),Td=rd(Sd),Ud=A$1({},ud,{touches:0,targetTouches:0,changedTouches:0,altKey:0,metaKey:0,ctrlKey:0,shiftKey:0,getModifierState:zd}),Vd=rd(Ud),Wd=A$1({},sd,{propertyName:0,elapsedTime:0,pseudoElement:0}),Xd=rd(Wd),Yd=A$1({},Ad,{deltaX:function(a){return "deltaX"in a?a.deltaX:"wheelDeltaX"in a?-a.wheelDeltaX:0},
    deltaY:function(a){return "deltaY"in a?a.deltaY:"wheelDeltaY"in a?-a.wheelDeltaY:"wheelDelta"in a?-a.wheelDelta:0},deltaZ:0,deltaMode:0}),Zd=rd(Yd),$d=[9,13,27,32],ae=ia&&"CompositionEvent"in window,be=null;ia&&"documentMode"in document&&(be=document.documentMode);var ce=ia&&"TextEvent"in window&&!be,de=ia&&(!ae||be&&8<be&&11>=be),ee=String.fromCharCode(32),fe=!1;
    function ge(a,b){switch(a){case "keyup":return -1!==$d.indexOf(b.keyCode);case "keydown":return 229!==b.keyCode;case "keypress":case "mousedown":case "focusout":return !0;default:return !1}}function he(a){a=a.detail;return "object"===typeof a&&"data"in a?a.data:null}var ie=!1;function je(a,b){switch(a){case "compositionend":return he(b);case "keypress":if(32!==b.which)return null;fe=!0;return ee;case "textInput":return a=b.data,a===ee&&fe?null:a;default:return null}}
    function ke(a,b){if(ie)return "compositionend"===a||!ae&&ge(a,b)?(a=nd(),md=ld=kd=null,ie=!1,a):null;switch(a){case "paste":return null;case "keypress":if(!(b.ctrlKey||b.altKey||b.metaKey)||b.ctrlKey&&b.altKey){if(b.char&&1<b.char.length)return b.char;if(b.which)return String.fromCharCode(b.which)}return null;case "compositionend":return de&&"ko"!==b.locale?null:b.data;default:return null}}
    var le={color:!0,date:!0,datetime:!0,"datetime-local":!0,email:!0,month:!0,number:!0,password:!0,range:!0,search:!0,tel:!0,text:!0,time:!0,url:!0,week:!0};function me(a){var b=a&&a.nodeName&&a.nodeName.toLowerCase();return "input"===b?!!le[a.type]:"textarea"===b?!0:!1}function ne(a,b,c,d){Eb(d);b=oe(b,"onChange");0<b.length&&(c=new td("onChange","change",null,c,d),a.push({event:c,listeners:b}));}var pe=null,qe=null;function re(a){se(a,0);}function te(a){var b=ue(a);if(Wa(b))return a}
    function ve(a,b){if("change"===a)return b}var we=!1;if(ia){var xe;if(ia){var ye="oninput"in document;if(!ye){var ze=document.createElement("div");ze.setAttribute("oninput","return;");ye="function"===typeof ze.oninput;}xe=ye;}else xe=!1;we=xe&&(!document.documentMode||9<document.documentMode);}function Ae(){pe&&(pe.detachEvent("onpropertychange",Be),qe=pe=null);}function Be(a){if("value"===a.propertyName&&te(qe)){var b=[];ne(b,qe,a,xb(a));Jb(re,b);}}
    function Ce(a,b,c){"focusin"===a?(Ae(),pe=b,qe=c,pe.attachEvent("onpropertychange",Be)):"focusout"===a&&Ae();}function De(a){if("selectionchange"===a||"keyup"===a||"keydown"===a)return te(qe)}function Ee(a,b){if("click"===a)return te(b)}function Fe(a,b){if("input"===a||"change"===a)return te(b)}function Ge(a,b){return a===b&&(0!==a||1/a===1/b)||a!==a&&b!==b}var He="function"===typeof Object.is?Object.is:Ge;
    function Ie(a,b){if(He(a,b))return !0;if("object"!==typeof a||null===a||"object"!==typeof b||null===b)return !1;var c=Object.keys(a),d=Object.keys(b);if(c.length!==d.length)return !1;for(d=0;d<c.length;d++){var e=c[d];if(!ja.call(b,e)||!He(a[e],b[e]))return !1}return !0}function Je(a){for(;a&&a.firstChild;)a=a.firstChild;return a}
    function Ke(a,b){var c=Je(a);a=0;for(var d;c;){if(3===c.nodeType){d=a+c.textContent.length;if(a<=b&&d>=b)return {node:c,offset:b-a};a=d;}a:{for(;c;){if(c.nextSibling){c=c.nextSibling;break a}c=c.parentNode;}c=void 0;}c=Je(c);}}function Le(a,b){return a&&b?a===b?!0:a&&3===a.nodeType?!1:b&&3===b.nodeType?Le(a,b.parentNode):"contains"in a?a.contains(b):a.compareDocumentPosition?!!(a.compareDocumentPosition(b)&16):!1:!1}
    function Me(){for(var a=window,b=Xa();b instanceof a.HTMLIFrameElement;){try{var c="string"===typeof b.contentWindow.location.href;}catch(d){c=!1;}if(c)a=b.contentWindow;else break;b=Xa(a.document);}return b}function Ne(a){var b=a&&a.nodeName&&a.nodeName.toLowerCase();return b&&("input"===b&&("text"===a.type||"search"===a.type||"tel"===a.type||"url"===a.type||"password"===a.type)||"textarea"===b||"true"===a.contentEditable)}
    function Oe(a){var b=Me(),c=a.focusedElem,d=a.selectionRange;if(b!==c&&c&&c.ownerDocument&&Le(c.ownerDocument.documentElement,c)){if(null!==d&&Ne(c))if(b=d.start,a=d.end,void 0===a&&(a=b),"selectionStart"in c)c.selectionStart=b,c.selectionEnd=Math.min(a,c.value.length);else if(a=(b=c.ownerDocument||document)&&b.defaultView||window,a.getSelection){a=a.getSelection();var e=c.textContent.length,f=Math.min(d.start,e);d=void 0===d.end?f:Math.min(d.end,e);!a.extend&&f>d&&(e=d,d=f,f=e);e=Ke(c,f);var g=Ke(c,
    d);e&&g&&(1!==a.rangeCount||a.anchorNode!==e.node||a.anchorOffset!==e.offset||a.focusNode!==g.node||a.focusOffset!==g.offset)&&(b=b.createRange(),b.setStart(e.node,e.offset),a.removeAllRanges(),f>d?(a.addRange(b),a.extend(g.node,g.offset)):(b.setEnd(g.node,g.offset),a.addRange(b)));}b=[];for(a=c;a=a.parentNode;)1===a.nodeType&&b.push({element:a,left:a.scrollLeft,top:a.scrollTop});"function"===typeof c.focus&&c.focus();for(c=0;c<b.length;c++)a=b[c],a.element.scrollLeft=a.left,a.element.scrollTop=a.top;}}
    var Pe=ia&&"documentMode"in document&&11>=document.documentMode,Qe=null,Re=null,Se=null,Te=!1;
    function Ue(a,b,c){var d=c.window===c?c.document:9===c.nodeType?c:c.ownerDocument;Te||null==Qe||Qe!==Xa(d)||(d=Qe,"selectionStart"in d&&Ne(d)?d={start:d.selectionStart,end:d.selectionEnd}:(d=(d.ownerDocument&&d.ownerDocument.defaultView||window).getSelection(),d={anchorNode:d.anchorNode,anchorOffset:d.anchorOffset,focusNode:d.focusNode,focusOffset:d.focusOffset}),Se&&Ie(Se,d)||(Se=d,d=oe(Re,"onSelect"),0<d.length&&(b=new td("onSelect","select",null,b,c),a.push({event:b,listeners:d}),b.target=Qe)));}
    function Ve(a,b){var c={};c[a.toLowerCase()]=b.toLowerCase();c["Webkit"+a]="webkit"+b;c["Moz"+a]="moz"+b;return c}var We={animationend:Ve("Animation","AnimationEnd"),animationiteration:Ve("Animation","AnimationIteration"),animationstart:Ve("Animation","AnimationStart"),transitionend:Ve("Transition","TransitionEnd")},Xe={},Ye={};
    ia&&(Ye=document.createElement("div").style,"AnimationEvent"in window||(delete We.animationend.animation,delete We.animationiteration.animation,delete We.animationstart.animation),"TransitionEvent"in window||delete We.transitionend.transition);function Ze(a){if(Xe[a])return Xe[a];if(!We[a])return a;var b=We[a],c;for(c in b)if(b.hasOwnProperty(c)&&c in Ye)return Xe[a]=b[c];return a}var $e=Ze("animationend"),af=Ze("animationiteration"),bf=Ze("animationstart"),cf=Ze("transitionend"),df=new Map,ef="abort auxClick cancel canPlay canPlayThrough click close contextMenu copy cut drag dragEnd dragEnter dragExit dragLeave dragOver dragStart drop durationChange emptied encrypted ended error gotPointerCapture input invalid keyDown keyPress keyUp load loadedData loadedMetadata loadStart lostPointerCapture mouseDown mouseMove mouseOut mouseOver mouseUp paste pause play playing pointerCancel pointerDown pointerMove pointerOut pointerOver pointerUp progress rateChange reset resize seeked seeking stalled submit suspend timeUpdate touchCancel touchEnd touchStart volumeChange scroll toggle touchMove waiting wheel".split(" ");
    function ff(a,b){df.set(a,b);fa(b,[a]);}for(var gf=0;gf<ef.length;gf++){var hf=ef[gf],jf=hf.toLowerCase(),kf=hf[0].toUpperCase()+hf.slice(1);ff(jf,"on"+kf);}ff($e,"onAnimationEnd");ff(af,"onAnimationIteration");ff(bf,"onAnimationStart");ff("dblclick","onDoubleClick");ff("focusin","onFocus");ff("focusout","onBlur");ff(cf,"onTransitionEnd");ha("onMouseEnter",["mouseout","mouseover"]);ha("onMouseLeave",["mouseout","mouseover"]);ha("onPointerEnter",["pointerout","pointerover"]);
    ha("onPointerLeave",["pointerout","pointerover"]);fa("onChange","change click focusin focusout input keydown keyup selectionchange".split(" "));fa("onSelect","focusout contextmenu dragend focusin keydown keyup mousedown mouseup selectionchange".split(" "));fa("onBeforeInput",["compositionend","keypress","textInput","paste"]);fa("onCompositionEnd","compositionend focusout keydown keypress keyup mousedown".split(" "));fa("onCompositionStart","compositionstart focusout keydown keypress keyup mousedown".split(" "));
    fa("onCompositionUpdate","compositionupdate focusout keydown keypress keyup mousedown".split(" "));var lf="abort canplay canplaythrough durationchange emptied encrypted ended error loadeddata loadedmetadata loadstart pause play playing progress ratechange resize seeked seeking stalled suspend timeupdate volumechange waiting".split(" "),mf=new Set("cancel close invalid load scroll toggle".split(" ").concat(lf));
    function nf(a,b,c){var d=a.type||"unknown-event";a.currentTarget=c;Ub(d,b,void 0,a);a.currentTarget=null;}
    function se(a,b){b=0!==(b&4);for(var c=0;c<a.length;c++){var d=a[c],e=d.event;d=d.listeners;a:{var f=void 0;if(b)for(var g=d.length-1;0<=g;g--){var h=d[g],k=h.instance,l=h.currentTarget;h=h.listener;if(k!==f&&e.isPropagationStopped())break a;nf(e,h,l);f=k;}else for(g=0;g<d.length;g++){h=d[g];k=h.instance;l=h.currentTarget;h=h.listener;if(k!==f&&e.isPropagationStopped())break a;nf(e,h,l);f=k;}}}if(Qb)throw a=Rb,Qb=!1,Rb=null,a;}
    function D(a,b){var c=b[of];void 0===c&&(c=b[of]=new Set);var d=a+"__bubble";c.has(d)||(pf(b,a,2,!1),c.add(d));}function qf(a,b,c){var d=0;b&&(d|=4);pf(c,a,d,b);}var rf="_reactListening"+Math.random().toString(36).slice(2);function sf(a){if(!a[rf]){a[rf]=!0;da.forEach(function(b){"selectionchange"!==b&&(mf.has(b)||qf(b,!1,a),qf(b,!0,a));});var b=9===a.nodeType?a:a.ownerDocument;null===b||b[rf]||(b[rf]=!0,qf("selectionchange",!1,b));}}
    function pf(a,b,c,d){switch(jd(b)){case 1:var e=ed;break;case 4:e=gd;break;default:e=fd;}c=e.bind(null,b,c,a);e=void 0;!Lb||"touchstart"!==b&&"touchmove"!==b&&"wheel"!==b||(e=!0);d?void 0!==e?a.addEventListener(b,c,{capture:!0,passive:e}):a.addEventListener(b,c,!0):void 0!==e?a.addEventListener(b,c,{passive:e}):a.addEventListener(b,c,!1);}
    function hd(a,b,c,d,e){var f=d;if(0===(b&1)&&0===(b&2)&&null!==d)a:for(;;){if(null===d)return;var g=d.tag;if(3===g||4===g){var h=d.stateNode.containerInfo;if(h===e||8===h.nodeType&&h.parentNode===e)break;if(4===g)for(g=d.return;null!==g;){var k=g.tag;if(3===k||4===k)if(k=g.stateNode.containerInfo,k===e||8===k.nodeType&&k.parentNode===e)return;g=g.return;}for(;null!==h;){g=Wc(h);if(null===g)return;k=g.tag;if(5===k||6===k){d=f=g;continue a}h=h.parentNode;}}d=d.return;}Jb(function(){var d=f,e=xb(c),g=[];
    a:{var h=df.get(a);if(void 0!==h){var k=td,n=a;switch(a){case "keypress":if(0===od(c))break a;case "keydown":case "keyup":k=Rd;break;case "focusin":n="focus";k=Fd;break;case "focusout":n="blur";k=Fd;break;case "beforeblur":case "afterblur":k=Fd;break;case "click":if(2===c.button)break a;case "auxclick":case "dblclick":case "mousedown":case "mousemove":case "mouseup":case "mouseout":case "mouseover":case "contextmenu":k=Bd;break;case "drag":case "dragend":case "dragenter":case "dragexit":case "dragleave":case "dragover":case "dragstart":case "drop":k=
    Dd;break;case "touchcancel":case "touchend":case "touchmove":case "touchstart":k=Vd;break;case $e:case af:case bf:k=Hd;break;case cf:k=Xd;break;case "scroll":k=vd;break;case "wheel":k=Zd;break;case "copy":case "cut":case "paste":k=Jd;break;case "gotpointercapture":case "lostpointercapture":case "pointercancel":case "pointerdown":case "pointermove":case "pointerout":case "pointerover":case "pointerup":k=Td;}var t=0!==(b&4),J=!t&&"scroll"===a,x=t?null!==h?h+"Capture":null:h;t=[];for(var w=d,u;null!==
    w;){u=w;var F=u.stateNode;5===u.tag&&null!==F&&(u=F,null!==x&&(F=Kb(w,x),null!=F&&t.push(tf(w,F,u))));if(J)break;w=w.return;}0<t.length&&(h=new k(h,n,null,c,e),g.push({event:h,listeners:t}));}}if(0===(b&7)){a:{h="mouseover"===a||"pointerover"===a;k="mouseout"===a||"pointerout"===a;if(h&&c!==wb&&(n=c.relatedTarget||c.fromElement)&&(Wc(n)||n[uf]))break a;if(k||h){h=e.window===e?e:(h=e.ownerDocument)?h.defaultView||h.parentWindow:window;if(k){if(n=c.relatedTarget||c.toElement,k=d,n=n?Wc(n):null,null!==
    n&&(J=Vb(n),n!==J||5!==n.tag&&6!==n.tag))n=null;}else k=null,n=d;if(k!==n){t=Bd;F="onMouseLeave";x="onMouseEnter";w="mouse";if("pointerout"===a||"pointerover"===a)t=Td,F="onPointerLeave",x="onPointerEnter",w="pointer";J=null==k?h:ue(k);u=null==n?h:ue(n);h=new t(F,w+"leave",k,c,e);h.target=J;h.relatedTarget=u;F=null;Wc(e)===d&&(t=new t(x,w+"enter",n,c,e),t.target=u,t.relatedTarget=J,F=t);J=F;if(k&&n)b:{t=k;x=n;w=0;for(u=t;u;u=vf(u))w++;u=0;for(F=x;F;F=vf(F))u++;for(;0<w-u;)t=vf(t),w--;for(;0<u-w;)x=
    vf(x),u--;for(;w--;){if(t===x||null!==x&&t===x.alternate)break b;t=vf(t);x=vf(x);}t=null;}else t=null;null!==k&&wf(g,h,k,t,!1);null!==n&&null!==J&&wf(g,J,n,t,!0);}}}a:{h=d?ue(d):window;k=h.nodeName&&h.nodeName.toLowerCase();if("select"===k||"input"===k&&"file"===h.type)var na=ve;else if(me(h))if(we)na=Fe;else {na=De;var xa=Ce;}else (k=h.nodeName)&&"input"===k.toLowerCase()&&("checkbox"===h.type||"radio"===h.type)&&(na=Ee);if(na&&(na=na(a,d))){ne(g,na,c,e);break a}xa&&xa(a,h,d);"focusout"===a&&(xa=h._wrapperState)&&
    xa.controlled&&"number"===h.type&&cb(h,"number",h.value);}xa=d?ue(d):window;switch(a){case "focusin":if(me(xa)||"true"===xa.contentEditable)Qe=xa,Re=d,Se=null;break;case "focusout":Se=Re=Qe=null;break;case "mousedown":Te=!0;break;case "contextmenu":case "mouseup":case "dragend":Te=!1;Ue(g,c,e);break;case "selectionchange":if(Pe)break;case "keydown":case "keyup":Ue(g,c,e);}var $a;if(ae)b:{switch(a){case "compositionstart":var ba="onCompositionStart";break b;case "compositionend":ba="onCompositionEnd";
    break b;case "compositionupdate":ba="onCompositionUpdate";break b}ba=void 0;}else ie?ge(a,c)&&(ba="onCompositionEnd"):"keydown"===a&&229===c.keyCode&&(ba="onCompositionStart");ba&&(de&&"ko"!==c.locale&&(ie||"onCompositionStart"!==ba?"onCompositionEnd"===ba&&ie&&($a=nd()):(kd=e,ld="value"in kd?kd.value:kd.textContent,ie=!0)),xa=oe(d,ba),0<xa.length&&(ba=new Ld(ba,a,null,c,e),g.push({event:ba,listeners:xa}),$a?ba.data=$a:($a=he(c),null!==$a&&(ba.data=$a))));if($a=ce?je(a,c):ke(a,c))d=oe(d,"onBeforeInput"),
    0<d.length&&(e=new Ld("onBeforeInput","beforeinput",null,c,e),g.push({event:e,listeners:d}),e.data=$a);}se(g,b);});}function tf(a,b,c){return {instance:a,listener:b,currentTarget:c}}function oe(a,b){for(var c=b+"Capture",d=[];null!==a;){var e=a,f=e.stateNode;5===e.tag&&null!==f&&(e=f,f=Kb(a,c),null!=f&&d.unshift(tf(a,f,e)),f=Kb(a,b),null!=f&&d.push(tf(a,f,e)));a=a.return;}return d}function vf(a){if(null===a)return null;do a=a.return;while(a&&5!==a.tag);return a?a:null}
    function wf(a,b,c,d,e){for(var f=b._reactName,g=[];null!==c&&c!==d;){var h=c,k=h.alternate,l=h.stateNode;if(null!==k&&k===d)break;5===h.tag&&null!==l&&(h=l,e?(k=Kb(c,f),null!=k&&g.unshift(tf(c,k,h))):e||(k=Kb(c,f),null!=k&&g.push(tf(c,k,h))));c=c.return;}0!==g.length&&a.push({event:b,listeners:g});}var xf=/\r\n?/g,yf=/\u0000|\uFFFD/g;function zf(a){return ("string"===typeof a?a:""+a).replace(xf,"\n").replace(yf,"")}function Af(a,b,c){b=zf(b);if(zf(a)!==b&&c)throw Error(p$3(425));}function Bf(){}
    var Cf=null,Df=null;function Ef(a,b){return "textarea"===a||"noscript"===a||"string"===typeof b.children||"number"===typeof b.children||"object"===typeof b.dangerouslySetInnerHTML&&null!==b.dangerouslySetInnerHTML&&null!=b.dangerouslySetInnerHTML.__html}
    var Ff="function"===typeof setTimeout?setTimeout:void 0,Gf="function"===typeof clearTimeout?clearTimeout:void 0,Hf="function"===typeof Promise?Promise:void 0,Jf="function"===typeof queueMicrotask?queueMicrotask:"undefined"!==typeof Hf?function(a){return Hf.resolve(null).then(a).catch(If)}:Ff;function If(a){setTimeout(function(){throw a;});}
    function Kf(a,b){var c=b,d=0;do{var e=c.nextSibling;a.removeChild(c);if(e&&8===e.nodeType)if(c=e.data,"/$"===c){if(0===d){a.removeChild(e);bd(b);return}d--;}else "$"!==c&&"$?"!==c&&"$!"!==c||d++;c=e;}while(c);bd(b);}function Lf(a){for(;null!=a;a=a.nextSibling){var b=a.nodeType;if(1===b||3===b)break;if(8===b){b=a.data;if("$"===b||"$!"===b||"$?"===b)break;if("/$"===b)return null}}return a}
    function Mf(a){a=a.previousSibling;for(var b=0;a;){if(8===a.nodeType){var c=a.data;if("$"===c||"$!"===c||"$?"===c){if(0===b)return a;b--;}else "/$"===c&&b++;}a=a.previousSibling;}return null}var Nf=Math.random().toString(36).slice(2),Of="__reactFiber$"+Nf,Pf="__reactProps$"+Nf,uf="__reactContainer$"+Nf,of="__reactEvents$"+Nf,Qf="__reactListeners$"+Nf,Rf="__reactHandles$"+Nf;
    function Wc(a){var b=a[Of];if(b)return b;for(var c=a.parentNode;c;){if(b=c[uf]||c[Of]){c=b.alternate;if(null!==b.child||null!==c&&null!==c.child)for(a=Mf(a);null!==a;){if(c=a[Of])return c;a=Mf(a);}return b}a=c;c=a.parentNode;}return null}function Cb(a){a=a[Of]||a[uf];return !a||5!==a.tag&&6!==a.tag&&13!==a.tag&&3!==a.tag?null:a}function ue(a){if(5===a.tag||6===a.tag)return a.stateNode;throw Error(p$3(33));}function Db(a){return a[Pf]||null}var Sf=[],Tf=-1;function Uf(a){return {current:a}}
    function E(a){0>Tf||(a.current=Sf[Tf],Sf[Tf]=null,Tf--);}function G(a,b){Tf++;Sf[Tf]=a.current;a.current=b;}var Vf={},H=Uf(Vf),Wf=Uf(!1),Xf=Vf;function Yf(a,b){var c=a.type.contextTypes;if(!c)return Vf;var d=a.stateNode;if(d&&d.__reactInternalMemoizedUnmaskedChildContext===b)return d.__reactInternalMemoizedMaskedChildContext;var e={},f;for(f in c)e[f]=b[f];d&&(a=a.stateNode,a.__reactInternalMemoizedUnmaskedChildContext=b,a.__reactInternalMemoizedMaskedChildContext=e);return e}
    function Zf(a){a=a.childContextTypes;return null!==a&&void 0!==a}function $f(){E(Wf);E(H);}function ag(a,b,c){if(H.current!==Vf)throw Error(p$3(168));G(H,b);G(Wf,c);}function bg(a,b,c){var d=a.stateNode;b=b.childContextTypes;if("function"!==typeof d.getChildContext)return c;d=d.getChildContext();for(var e in d)if(!(e in b))throw Error(p$3(108,Ra(a)||"Unknown",e));return A$1({},c,d)}
    function cg(a){a=(a=a.stateNode)&&a.__reactInternalMemoizedMergedChildContext||Vf;Xf=H.current;G(H,a);G(Wf,Wf.current);return !0}function dg(a,b,c){var d=a.stateNode;if(!d)throw Error(p$3(169));c?(a=bg(a,b,Xf),d.__reactInternalMemoizedMergedChildContext=a,E(Wf),E(H),G(H,a)):E(Wf);G(Wf,c);}var eg=null,fg=!1,gg=!1;function hg(a){null===eg?eg=[a]:eg.push(a);}function ig(a){fg=!0;hg(a);}
    function jg(){if(!gg&&null!==eg){gg=!0;var a=0,b=C;try{var c=eg;for(C=1;a<c.length;a++){var d=c[a];do d=d(!0);while(null!==d)}eg=null;fg=!1;}catch(e){throw null!==eg&&(eg=eg.slice(a+1)),ac(fc,jg),e;}finally{C=b,gg=!1;}}return null}var kg=[],lg=0,mg=null,ng=0,og=[],pg=0,qg=null,rg=1,sg="";function tg(a,b){kg[lg++]=ng;kg[lg++]=mg;mg=a;ng=b;}
    function ug(a,b,c){og[pg++]=rg;og[pg++]=sg;og[pg++]=qg;qg=a;var d=rg;a=sg;var e=32-oc(d)-1;d&=~(1<<e);c+=1;var f=32-oc(b)+e;if(30<f){var g=e-e%5;f=(d&(1<<g)-1).toString(32);d>>=g;e-=g;rg=1<<32-oc(b)+e|c<<e|d;sg=f+a;}else rg=1<<f|c<<e|d,sg=a;}function vg(a){null!==a.return&&(tg(a,1),ug(a,1,0));}function wg(a){for(;a===mg;)mg=kg[--lg],kg[lg]=null,ng=kg[--lg],kg[lg]=null;for(;a===qg;)qg=og[--pg],og[pg]=null,sg=og[--pg],og[pg]=null,rg=og[--pg],og[pg]=null;}var xg=null,yg=null,I=!1,zg=null;
    function Ag(a,b){var c=Bg(5,null,null,0);c.elementType="DELETED";c.stateNode=b;c.return=a;b=a.deletions;null===b?(a.deletions=[c],a.flags|=16):b.push(c);}
    function Cg(a,b){switch(a.tag){case 5:var c=a.type;b=1!==b.nodeType||c.toLowerCase()!==b.nodeName.toLowerCase()?null:b;return null!==b?(a.stateNode=b,xg=a,yg=Lf(b.firstChild),!0):!1;case 6:return b=""===a.pendingProps||3!==b.nodeType?null:b,null!==b?(a.stateNode=b,xg=a,yg=null,!0):!1;case 13:return b=8!==b.nodeType?null:b,null!==b?(c=null!==qg?{id:rg,overflow:sg}:null,a.memoizedState={dehydrated:b,treeContext:c,retryLane:1073741824},c=Bg(18,null,null,0),c.stateNode=b,c.return=a,a.child=c,xg=a,yg=
    null,!0):!1;default:return !1}}function Dg(a){return 0!==(a.mode&1)&&0===(a.flags&128)}function Eg(a){if(I){var b=yg;if(b){var c=b;if(!Cg(a,b)){if(Dg(a))throw Error(p$3(418));b=Lf(c.nextSibling);var d=xg;b&&Cg(a,b)?Ag(d,c):(a.flags=a.flags&-4097|2,I=!1,xg=a);}}else {if(Dg(a))throw Error(p$3(418));a.flags=a.flags&-4097|2;I=!1;xg=a;}}}function Fg(a){for(a=a.return;null!==a&&5!==a.tag&&3!==a.tag&&13!==a.tag;)a=a.return;xg=a;}
    function Gg(a){if(a!==xg)return !1;if(!I)return Fg(a),I=!0,!1;var b;(b=3!==a.tag)&&!(b=5!==a.tag)&&(b=a.type,b="head"!==b&&"body"!==b&&!Ef(a.type,a.memoizedProps));if(b&&(b=yg)){if(Dg(a))throw Hg(),Error(p$3(418));for(;b;)Ag(a,b),b=Lf(b.nextSibling);}Fg(a);if(13===a.tag){a=a.memoizedState;a=null!==a?a.dehydrated:null;if(!a)throw Error(p$3(317));a:{a=a.nextSibling;for(b=0;a;){if(8===a.nodeType){var c=a.data;if("/$"===c){if(0===b){yg=Lf(a.nextSibling);break a}b--;}else "$"!==c&&"$!"!==c&&"$?"!==c||b++;}a=a.nextSibling;}yg=
    null;}}else yg=xg?Lf(a.stateNode.nextSibling):null;return !0}function Hg(){for(var a=yg;a;)a=Lf(a.nextSibling);}function Ig(){yg=xg=null;I=!1;}function Jg(a){null===zg?zg=[a]:zg.push(a);}var Kg=ua.ReactCurrentBatchConfig;function Lg(a,b){if(a&&a.defaultProps){b=A$1({},b);a=a.defaultProps;for(var c in a)void 0===b[c]&&(b[c]=a[c]);return b}return b}var Mg=Uf(null),Ng=null,Og=null,Pg=null;function Qg(){Pg=Og=Ng=null;}function Rg(a){var b=Mg.current;E(Mg);a._currentValue=b;}
    function Sg(a,b,c){for(;null!==a;){var d=a.alternate;(a.childLanes&b)!==b?(a.childLanes|=b,null!==d&&(d.childLanes|=b)):null!==d&&(d.childLanes&b)!==b&&(d.childLanes|=b);if(a===c)break;a=a.return;}}function Tg(a,b){Ng=a;Pg=Og=null;a=a.dependencies;null!==a&&null!==a.firstContext&&(0!==(a.lanes&b)&&(Ug=!0),a.firstContext=null);}
    function Vg(a){var b=a._currentValue;if(Pg!==a)if(a={context:a,memoizedValue:b,next:null},null===Og){if(null===Ng)throw Error(p$3(308));Og=a;Ng.dependencies={lanes:0,firstContext:a};}else Og=Og.next=a;return b}var Wg=null;function Xg(a){null===Wg?Wg=[a]:Wg.push(a);}function Yg(a,b,c,d){var e=b.interleaved;null===e?(c.next=c,Xg(b)):(c.next=e.next,e.next=c);b.interleaved=c;return Zg(a,d)}
    function Zg(a,b){a.lanes|=b;var c=a.alternate;null!==c&&(c.lanes|=b);c=a;for(a=a.return;null!==a;)a.childLanes|=b,c=a.alternate,null!==c&&(c.childLanes|=b),c=a,a=a.return;return 3===c.tag?c.stateNode:null}var $g=!1;function ah(a){a.updateQueue={baseState:a.memoizedState,firstBaseUpdate:null,lastBaseUpdate:null,shared:{pending:null,interleaved:null,lanes:0},effects:null};}
    function bh(a,b){a=a.updateQueue;b.updateQueue===a&&(b.updateQueue={baseState:a.baseState,firstBaseUpdate:a.firstBaseUpdate,lastBaseUpdate:a.lastBaseUpdate,shared:a.shared,effects:a.effects});}function ch(a,b){return {eventTime:a,lane:b,tag:0,payload:null,callback:null,next:null}}
    function dh(a,b,c){var d=a.updateQueue;if(null===d)return null;d=d.shared;if(0!==(K&2)){var e=d.pending;null===e?b.next=b:(b.next=e.next,e.next=b);d.pending=b;return Zg(a,c)}e=d.interleaved;null===e?(b.next=b,Xg(d)):(b.next=e.next,e.next=b);d.interleaved=b;return Zg(a,c)}function eh(a,b,c){b=b.updateQueue;if(null!==b&&(b=b.shared,0!==(c&4194240))){var d=b.lanes;d&=a.pendingLanes;c|=d;b.lanes=c;Cc(a,c);}}
    function fh(a,b){var c=a.updateQueue,d=a.alternate;if(null!==d&&(d=d.updateQueue,c===d)){var e=null,f=null;c=c.firstBaseUpdate;if(null!==c){do{var g={eventTime:c.eventTime,lane:c.lane,tag:c.tag,payload:c.payload,callback:c.callback,next:null};null===f?e=f=g:f=f.next=g;c=c.next;}while(null!==c);null===f?e=f=b:f=f.next=b;}else e=f=b;c={baseState:d.baseState,firstBaseUpdate:e,lastBaseUpdate:f,shared:d.shared,effects:d.effects};a.updateQueue=c;return}a=c.lastBaseUpdate;null===a?c.firstBaseUpdate=b:a.next=
    b;c.lastBaseUpdate=b;}
    function gh(a,b,c,d){var e=a.updateQueue;$g=!1;var f=e.firstBaseUpdate,g=e.lastBaseUpdate,h=e.shared.pending;if(null!==h){e.shared.pending=null;var k=h,l=k.next;k.next=null;null===g?f=l:g.next=l;g=k;var m=a.alternate;null!==m&&(m=m.updateQueue,h=m.lastBaseUpdate,h!==g&&(null===h?m.firstBaseUpdate=l:h.next=l,m.lastBaseUpdate=k));}if(null!==f){var q=e.baseState;g=0;m=l=k=null;h=f;do{var r=h.lane,y=h.eventTime;if((d&r)===r){null!==m&&(m=m.next={eventTime:y,lane:0,tag:h.tag,payload:h.payload,callback:h.callback,
    next:null});a:{var n=a,t=h;r=b;y=c;switch(t.tag){case 1:n=t.payload;if("function"===typeof n){q=n.call(y,q,r);break a}q=n;break a;case 3:n.flags=n.flags&-65537|128;case 0:n=t.payload;r="function"===typeof n?n.call(y,q,r):n;if(null===r||void 0===r)break a;q=A$1({},q,r);break a;case 2:$g=!0;}}null!==h.callback&&0!==h.lane&&(a.flags|=64,r=e.effects,null===r?e.effects=[h]:r.push(h));}else y={eventTime:y,lane:r,tag:h.tag,payload:h.payload,callback:h.callback,next:null},null===m?(l=m=y,k=q):m=m.next=y,g|=r;
    h=h.next;if(null===h)if(h=e.shared.pending,null===h)break;else r=h,h=r.next,r.next=null,e.lastBaseUpdate=r,e.shared.pending=null;}while(1);null===m&&(k=q);e.baseState=k;e.firstBaseUpdate=l;e.lastBaseUpdate=m;b=e.shared.interleaved;if(null!==b){e=b;do g|=e.lane,e=e.next;while(e!==b)}else null===f&&(e.shared.lanes=0);hh|=g;a.lanes=g;a.memoizedState=q;}}
    function ih(a,b,c){a=b.effects;b.effects=null;if(null!==a)for(b=0;b<a.length;b++){var d=a[b],e=d.callback;if(null!==e){d.callback=null;d=c;if("function"!==typeof e)throw Error(p$3(191,e));e.call(d);}}}var jh=(new aa.Component).refs;function kh(a,b,c,d){b=a.memoizedState;c=c(d,b);c=null===c||void 0===c?b:A$1({},b,c);a.memoizedState=c;0===a.lanes&&(a.updateQueue.baseState=c);}
    var nh={isMounted:function(a){return (a=a._reactInternals)?Vb(a)===a:!1},enqueueSetState:function(a,b,c){a=a._reactInternals;var d=L(),e=lh(a),f=ch(d,e);f.payload=b;void 0!==c&&null!==c&&(f.callback=c);b=dh(a,f,e);null!==b&&(mh(b,a,e,d),eh(b,a,e));},enqueueReplaceState:function(a,b,c){a=a._reactInternals;var d=L(),e=lh(a),f=ch(d,e);f.tag=1;f.payload=b;void 0!==c&&null!==c&&(f.callback=c);b=dh(a,f,e);null!==b&&(mh(b,a,e,d),eh(b,a,e));},enqueueForceUpdate:function(a,b){a=a._reactInternals;var c=L(),d=
    lh(a),e=ch(c,d);e.tag=2;void 0!==b&&null!==b&&(e.callback=b);b=dh(a,e,d);null!==b&&(mh(b,a,d,c),eh(b,a,d));}};function oh(a,b,c,d,e,f,g){a=a.stateNode;return "function"===typeof a.shouldComponentUpdate?a.shouldComponentUpdate(d,f,g):b.prototype&&b.prototype.isPureReactComponent?!Ie(c,d)||!Ie(e,f):!0}
    function ph(a,b,c){var d=!1,e=Vf;var f=b.contextType;"object"===typeof f&&null!==f?f=Vg(f):(e=Zf(b)?Xf:H.current,d=b.contextTypes,f=(d=null!==d&&void 0!==d)?Yf(a,e):Vf);b=new b(c,f);a.memoizedState=null!==b.state&&void 0!==b.state?b.state:null;b.updater=nh;a.stateNode=b;b._reactInternals=a;d&&(a=a.stateNode,a.__reactInternalMemoizedUnmaskedChildContext=e,a.__reactInternalMemoizedMaskedChildContext=f);return b}
    function qh(a,b,c,d){a=b.state;"function"===typeof b.componentWillReceiveProps&&b.componentWillReceiveProps(c,d);"function"===typeof b.UNSAFE_componentWillReceiveProps&&b.UNSAFE_componentWillReceiveProps(c,d);b.state!==a&&nh.enqueueReplaceState(b,b.state,null);}
    function rh(a,b,c,d){var e=a.stateNode;e.props=c;e.state=a.memoizedState;e.refs=jh;ah(a);var f=b.contextType;"object"===typeof f&&null!==f?e.context=Vg(f):(f=Zf(b)?Xf:H.current,e.context=Yf(a,f));e.state=a.memoizedState;f=b.getDerivedStateFromProps;"function"===typeof f&&(kh(a,b,f,c),e.state=a.memoizedState);"function"===typeof b.getDerivedStateFromProps||"function"===typeof e.getSnapshotBeforeUpdate||"function"!==typeof e.UNSAFE_componentWillMount&&"function"!==typeof e.componentWillMount||(b=e.state,
    "function"===typeof e.componentWillMount&&e.componentWillMount(),"function"===typeof e.UNSAFE_componentWillMount&&e.UNSAFE_componentWillMount(),b!==e.state&&nh.enqueueReplaceState(e,e.state,null),gh(a,c,e,d),e.state=a.memoizedState);"function"===typeof e.componentDidMount&&(a.flags|=4194308);}
    function sh(a,b,c){a=c.ref;if(null!==a&&"function"!==typeof a&&"object"!==typeof a){if(c._owner){c=c._owner;if(c){if(1!==c.tag)throw Error(p$3(309));var d=c.stateNode;}if(!d)throw Error(p$3(147,a));var e=d,f=""+a;if(null!==b&&null!==b.ref&&"function"===typeof b.ref&&b.ref._stringRef===f)return b.ref;b=function(a){var b=e.refs;b===jh&&(b=e.refs={});null===a?delete b[f]:b[f]=a;};b._stringRef=f;return b}if("string"!==typeof a)throw Error(p$3(284));if(!c._owner)throw Error(p$3(290,a));}return a}
    function th(a,b){a=Object.prototype.toString.call(b);throw Error(p$3(31,"[object Object]"===a?"object with keys {"+Object.keys(b).join(", ")+"}":a));}function uh(a){var b=a._init;return b(a._payload)}
    function vh(a){function b(b,c){if(a){var d=b.deletions;null===d?(b.deletions=[c],b.flags|=16):d.push(c);}}function c(c,d){if(!a)return null;for(;null!==d;)b(c,d),d=d.sibling;return null}function d(a,b){for(a=new Map;null!==b;)null!==b.key?a.set(b.key,b):a.set(b.index,b),b=b.sibling;return a}function e(a,b){a=wh(a,b);a.index=0;a.sibling=null;return a}function f(b,c,d){b.index=d;if(!a)return b.flags|=1048576,c;d=b.alternate;if(null!==d)return d=d.index,d<c?(b.flags|=2,c):d;b.flags|=2;return c}function g(b){a&&
    null===b.alternate&&(b.flags|=2);return b}function h(a,b,c,d){if(null===b||6!==b.tag)return b=xh(c,a.mode,d),b.return=a,b;b=e(b,c);b.return=a;return b}function k(a,b,c,d){var f=c.type;if(f===ya)return m(a,b,c.props.children,d,c.key);if(null!==b&&(b.elementType===f||"object"===typeof f&&null!==f&&f.$$typeof===Ha&&uh(f)===b.type))return d=e(b,c.props),d.ref=sh(a,b,c),d.return=a,d;d=yh(c.type,c.key,c.props,null,a.mode,d);d.ref=sh(a,b,c);d.return=a;return d}function l(a,b,c,d){if(null===b||4!==b.tag||
    b.stateNode.containerInfo!==c.containerInfo||b.stateNode.implementation!==c.implementation)return b=zh(c,a.mode,d),b.return=a,b;b=e(b,c.children||[]);b.return=a;return b}function m(a,b,c,d,f){if(null===b||7!==b.tag)return b=Ah(c,a.mode,d,f),b.return=a,b;b=e(b,c);b.return=a;return b}function q(a,b,c){if("string"===typeof b&&""!==b||"number"===typeof b)return b=xh(""+b,a.mode,c),b.return=a,b;if("object"===typeof b&&null!==b){switch(b.$$typeof){case va:return c=yh(b.type,b.key,b.props,null,a.mode,c),
    c.ref=sh(a,null,b),c.return=a,c;case wa:return b=zh(b,a.mode,c),b.return=a,b;case Ha:var d=b._init;return q(a,d(b._payload),c)}if(eb(b)||Ka(b))return b=Ah(b,a.mode,c,null),b.return=a,b;th(a,b);}return null}function r(a,b,c,d){var e=null!==b?b.key:null;if("string"===typeof c&&""!==c||"number"===typeof c)return null!==e?null:h(a,b,""+c,d);if("object"===typeof c&&null!==c){switch(c.$$typeof){case va:return c.key===e?k(a,b,c,d):null;case wa:return c.key===e?l(a,b,c,d):null;case Ha:return e=c._init,r(a,
    b,e(c._payload),d)}if(eb(c)||Ka(c))return null!==e?null:m(a,b,c,d,null);th(a,c);}return null}function y(a,b,c,d,e){if("string"===typeof d&&""!==d||"number"===typeof d)return a=a.get(c)||null,h(b,a,""+d,e);if("object"===typeof d&&null!==d){switch(d.$$typeof){case va:return a=a.get(null===d.key?c:d.key)||null,k(b,a,d,e);case wa:return a=a.get(null===d.key?c:d.key)||null,l(b,a,d,e);case Ha:var f=d._init;return y(a,b,c,f(d._payload),e)}if(eb(d)||Ka(d))return a=a.get(c)||null,m(b,a,d,e,null);th(b,d);}return null}
    function n(e,g,h,k){for(var l=null,m=null,u=g,w=g=0,x=null;null!==u&&w<h.length;w++){u.index>w?(x=u,u=null):x=u.sibling;var n=r(e,u,h[w],k);if(null===n){null===u&&(u=x);break}a&&u&&null===n.alternate&&b(e,u);g=f(n,g,w);null===m?l=n:m.sibling=n;m=n;u=x;}if(w===h.length)return c(e,u),I&&tg(e,w),l;if(null===u){for(;w<h.length;w++)u=q(e,h[w],k),null!==u&&(g=f(u,g,w),null===m?l=u:m.sibling=u,m=u);I&&tg(e,w);return l}for(u=d(e,u);w<h.length;w++)x=y(u,e,w,h[w],k),null!==x&&(a&&null!==x.alternate&&u.delete(null===
    x.key?w:x.key),g=f(x,g,w),null===m?l=x:m.sibling=x,m=x);a&&u.forEach(function(a){return b(e,a)});I&&tg(e,w);return l}function t(e,g,h,k){var l=Ka(h);if("function"!==typeof l)throw Error(p$3(150));h=l.call(h);if(null==h)throw Error(p$3(151));for(var u=l=null,m=g,w=g=0,x=null,n=h.next();null!==m&&!n.done;w++,n=h.next()){m.index>w?(x=m,m=null):x=m.sibling;var t=r(e,m,n.value,k);if(null===t){null===m&&(m=x);break}a&&m&&null===t.alternate&&b(e,m);g=f(t,g,w);null===u?l=t:u.sibling=t;u=t;m=x;}if(n.done)return c(e,
    m),I&&tg(e,w),l;if(null===m){for(;!n.done;w++,n=h.next())n=q(e,n.value,k),null!==n&&(g=f(n,g,w),null===u?l=n:u.sibling=n,u=n);I&&tg(e,w);return l}for(m=d(e,m);!n.done;w++,n=h.next())n=y(m,e,w,n.value,k),null!==n&&(a&&null!==n.alternate&&m.delete(null===n.key?w:n.key),g=f(n,g,w),null===u?l=n:u.sibling=n,u=n);a&&m.forEach(function(a){return b(e,a)});I&&tg(e,w);return l}function J(a,d,f,h){"object"===typeof f&&null!==f&&f.type===ya&&null===f.key&&(f=f.props.children);if("object"===typeof f&&null!==f){switch(f.$$typeof){case va:a:{for(var k=
    f.key,l=d;null!==l;){if(l.key===k){k=f.type;if(k===ya){if(7===l.tag){c(a,l.sibling);d=e(l,f.props.children);d.return=a;a=d;break a}}else if(l.elementType===k||"object"===typeof k&&null!==k&&k.$$typeof===Ha&&uh(k)===l.type){c(a,l.sibling);d=e(l,f.props);d.ref=sh(a,l,f);d.return=a;a=d;break a}c(a,l);break}else b(a,l);l=l.sibling;}f.type===ya?(d=Ah(f.props.children,a.mode,h,f.key),d.return=a,a=d):(h=yh(f.type,f.key,f.props,null,a.mode,h),h.ref=sh(a,d,f),h.return=a,a=h);}return g(a);case wa:a:{for(l=f.key;null!==
    d;){if(d.key===l)if(4===d.tag&&d.stateNode.containerInfo===f.containerInfo&&d.stateNode.implementation===f.implementation){c(a,d.sibling);d=e(d,f.children||[]);d.return=a;a=d;break a}else {c(a,d);break}else b(a,d);d=d.sibling;}d=zh(f,a.mode,h);d.return=a;a=d;}return g(a);case Ha:return l=f._init,J(a,d,l(f._payload),h)}if(eb(f))return n(a,d,f,h);if(Ka(f))return t(a,d,f,h);th(a,f);}return "string"===typeof f&&""!==f||"number"===typeof f?(f=""+f,null!==d&&6===d.tag?(c(a,d.sibling),d=e(d,f),d.return=a,a=d):
    (c(a,d),d=xh(f,a.mode,h),d.return=a,a=d),g(a)):c(a,d)}return J}var Bh=vh(!0),Ch=vh(!1),Dh={},Eh=Uf(Dh),Fh=Uf(Dh),Gh=Uf(Dh);function Hh(a){if(a===Dh)throw Error(p$3(174));return a}function Ih(a,b){G(Gh,b);G(Fh,a);G(Eh,Dh);a=b.nodeType;switch(a){case 9:case 11:b=(b=b.documentElement)?b.namespaceURI:lb$1(null,"");break;default:a=8===a?b.parentNode:b,b=a.namespaceURI||null,a=a.tagName,b=lb$1(b,a);}E(Eh);G(Eh,b);}function Jh(){E(Eh);E(Fh);E(Gh);}
    function Kh(a){Hh(Gh.current);var b=Hh(Eh.current);var c=lb$1(b,a.type);b!==c&&(G(Fh,a),G(Eh,c));}function Lh(a){Fh.current===a&&(E(Eh),E(Fh));}var M=Uf(0);
    function Mh(a){for(var b=a;null!==b;){if(13===b.tag){var c=b.memoizedState;if(null!==c&&(c=c.dehydrated,null===c||"$?"===c.data||"$!"===c.data))return b}else if(19===b.tag&&void 0!==b.memoizedProps.revealOrder){if(0!==(b.flags&128))return b}else if(null!==b.child){b.child.return=b;b=b.child;continue}if(b===a)break;for(;null===b.sibling;){if(null===b.return||b.return===a)return null;b=b.return;}b.sibling.return=b.return;b=b.sibling;}return null}var Nh=[];
    function Oh(){for(var a=0;a<Nh.length;a++)Nh[a]._workInProgressVersionPrimary=null;Nh.length=0;}var Ph=ua.ReactCurrentDispatcher,Qh=ua.ReactCurrentBatchConfig,Rh=0,N=null,O=null,P=null,Sh=!1,Th=!1,Uh=0,Vh=0;function Q(){throw Error(p$3(321));}function Wh(a,b){if(null===b)return !1;for(var c=0;c<b.length&&c<a.length;c++)if(!He(a[c],b[c]))return !1;return !0}
    function Xh(a,b,c,d,e,f){Rh=f;N=b;b.memoizedState=null;b.updateQueue=null;b.lanes=0;Ph.current=null===a||null===a.memoizedState?Yh:Zh;a=c(d,e);if(Th){f=0;do{Th=!1;Uh=0;if(25<=f)throw Error(p$3(301));f+=1;P=O=null;b.updateQueue=null;Ph.current=$h;a=c(d,e);}while(Th)}Ph.current=ai;b=null!==O&&null!==O.next;Rh=0;P=O=N=null;Sh=!1;if(b)throw Error(p$3(300));return a}function bi(){var a=0!==Uh;Uh=0;return a}
    function ci(){var a={memoizedState:null,baseState:null,baseQueue:null,queue:null,next:null};null===P?N.memoizedState=P=a:P=P.next=a;return P}function di(){if(null===O){var a=N.alternate;a=null!==a?a.memoizedState:null;}else a=O.next;var b=null===P?N.memoizedState:P.next;if(null!==b)P=b,O=a;else {if(null===a)throw Error(p$3(310));O=a;a={memoizedState:O.memoizedState,baseState:O.baseState,baseQueue:O.baseQueue,queue:O.queue,next:null};null===P?N.memoizedState=P=a:P=P.next=a;}return P}
    function ei(a,b){return "function"===typeof b?b(a):b}
    function fi(a){var b=di(),c=b.queue;if(null===c)throw Error(p$3(311));c.lastRenderedReducer=a;var d=O,e=d.baseQueue,f=c.pending;if(null!==f){if(null!==e){var g=e.next;e.next=f.next;f.next=g;}d.baseQueue=e=f;c.pending=null;}if(null!==e){f=e.next;d=d.baseState;var h=g=null,k=null,l=f;do{var m=l.lane;if((Rh&m)===m)null!==k&&(k=k.next={lane:0,action:l.action,hasEagerState:l.hasEagerState,eagerState:l.eagerState,next:null}),d=l.hasEagerState?l.eagerState:a(d,l.action);else {var q={lane:m,action:l.action,hasEagerState:l.hasEagerState,
    eagerState:l.eagerState,next:null};null===k?(h=k=q,g=d):k=k.next=q;N.lanes|=m;hh|=m;}l=l.next;}while(null!==l&&l!==f);null===k?g=d:k.next=h;He(d,b.memoizedState)||(Ug=!0);b.memoizedState=d;b.baseState=g;b.baseQueue=k;c.lastRenderedState=d;}a=c.interleaved;if(null!==a){e=a;do f=e.lane,N.lanes|=f,hh|=f,e=e.next;while(e!==a)}else null===e&&(c.lanes=0);return [b.memoizedState,c.dispatch]}
    function gi(a){var b=di(),c=b.queue;if(null===c)throw Error(p$3(311));c.lastRenderedReducer=a;var d=c.dispatch,e=c.pending,f=b.memoizedState;if(null!==e){c.pending=null;var g=e=e.next;do f=a(f,g.action),g=g.next;while(g!==e);He(f,b.memoizedState)||(Ug=!0);b.memoizedState=f;null===b.baseQueue&&(b.baseState=f);c.lastRenderedState=f;}return [f,d]}function hi(){}
    function ii(a,b){var c=N,d=di(),e=b(),f=!He(d.memoizedState,e);f&&(d.memoizedState=e,Ug=!0);d=d.queue;ji(ki.bind(null,c,d,a),[a]);if(d.getSnapshot!==b||f||null!==P&&P.memoizedState.tag&1){c.flags|=2048;li(9,mi.bind(null,c,d,e,b),void 0,null);if(null===R)throw Error(p$3(349));0!==(Rh&30)||ni(c,b,e);}return e}function ni(a,b,c){a.flags|=16384;a={getSnapshot:b,value:c};b=N.updateQueue;null===b?(b={lastEffect:null,stores:null},N.updateQueue=b,b.stores=[a]):(c=b.stores,null===c?b.stores=[a]:c.push(a));}
    function mi(a,b,c,d){b.value=c;b.getSnapshot=d;oi(b)&&pi(a);}function ki(a,b,c){return c(function(){oi(b)&&pi(a);})}function oi(a){var b=a.getSnapshot;a=a.value;try{var c=b();return !He(a,c)}catch(d){return !0}}function pi(a){var b=Zg(a,1);null!==b&&mh(b,a,1,-1);}
    function qi(a){var b=ci();"function"===typeof a&&(a=a());b.memoizedState=b.baseState=a;a={pending:null,interleaved:null,lanes:0,dispatch:null,lastRenderedReducer:ei,lastRenderedState:a};b.queue=a;a=a.dispatch=ri.bind(null,N,a);return [b.memoizedState,a]}
    function li(a,b,c,d){a={tag:a,create:b,destroy:c,deps:d,next:null};b=N.updateQueue;null===b?(b={lastEffect:null,stores:null},N.updateQueue=b,b.lastEffect=a.next=a):(c=b.lastEffect,null===c?b.lastEffect=a.next=a:(d=c.next,c.next=a,a.next=d,b.lastEffect=a));return a}function si(){return di().memoizedState}function ti(a,b,c,d){var e=ci();N.flags|=a;e.memoizedState=li(1|b,c,void 0,void 0===d?null:d);}
    function ui(a,b,c,d){var e=di();d=void 0===d?null:d;var f=void 0;if(null!==O){var g=O.memoizedState;f=g.destroy;if(null!==d&&Wh(d,g.deps)){e.memoizedState=li(b,c,f,d);return}}N.flags|=a;e.memoizedState=li(1|b,c,f,d);}function vi(a,b){return ti(8390656,8,a,b)}function ji(a,b){return ui(2048,8,a,b)}function wi(a,b){return ui(4,2,a,b)}function xi(a,b){return ui(4,4,a,b)}
    function yi(a,b){if("function"===typeof b)return a=a(),b(a),function(){b(null);};if(null!==b&&void 0!==b)return a=a(),b.current=a,function(){b.current=null;}}function zi(a,b,c){c=null!==c&&void 0!==c?c.concat([a]):null;return ui(4,4,yi.bind(null,b,a),c)}function Ai(){}function Bi(a,b){var c=di();b=void 0===b?null:b;var d=c.memoizedState;if(null!==d&&null!==b&&Wh(b,d[1]))return d[0];c.memoizedState=[a,b];return a}
    function Ci(a,b){var c=di();b=void 0===b?null:b;var d=c.memoizedState;if(null!==d&&null!==b&&Wh(b,d[1]))return d[0];a=a();c.memoizedState=[a,b];return a}function Di(a,b,c){if(0===(Rh&21))return a.baseState&&(a.baseState=!1,Ug=!0),a.memoizedState=c;He(c,b)||(c=yc(),N.lanes|=c,hh|=c,a.baseState=!0);return b}function Ei(a,b){var c=C;C=0!==c&&4>c?c:4;a(!0);var d=Qh.transition;Qh.transition={};try{a(!1),b();}finally{C=c,Qh.transition=d;}}function Fi(){return di().memoizedState}
    function Gi(a,b,c){var d=lh(a);c={lane:d,action:c,hasEagerState:!1,eagerState:null,next:null};if(Hi(a))Ii(b,c);else if(c=Yg(a,b,c,d),null!==c){var e=L();mh(c,a,d,e);Ji(c,b,d);}}
    function ri(a,b,c){var d=lh(a),e={lane:d,action:c,hasEagerState:!1,eagerState:null,next:null};if(Hi(a))Ii(b,e);else {var f=a.alternate;if(0===a.lanes&&(null===f||0===f.lanes)&&(f=b.lastRenderedReducer,null!==f))try{var g=b.lastRenderedState,h=f(g,c);e.hasEagerState=!0;e.eagerState=h;if(He(h,g)){var k=b.interleaved;null===k?(e.next=e,Xg(b)):(e.next=k.next,k.next=e);b.interleaved=e;return}}catch(l){}finally{}c=Yg(a,b,e,d);null!==c&&(e=L(),mh(c,a,d,e),Ji(c,b,d));}}
    function Hi(a){var b=a.alternate;return a===N||null!==b&&b===N}function Ii(a,b){Th=Sh=!0;var c=a.pending;null===c?b.next=b:(b.next=c.next,c.next=b);a.pending=b;}function Ji(a,b,c){if(0!==(c&4194240)){var d=b.lanes;d&=a.pendingLanes;c|=d;b.lanes=c;Cc(a,c);}}
    var ai={readContext:Vg,useCallback:Q,useContext:Q,useEffect:Q,useImperativeHandle:Q,useInsertionEffect:Q,useLayoutEffect:Q,useMemo:Q,useReducer:Q,useRef:Q,useState:Q,useDebugValue:Q,useDeferredValue:Q,useTransition:Q,useMutableSource:Q,useSyncExternalStore:Q,useId:Q,unstable_isNewReconciler:!1},Yh={readContext:Vg,useCallback:function(a,b){ci().memoizedState=[a,void 0===b?null:b];return a},useContext:Vg,useEffect:vi,useImperativeHandle:function(a,b,c){c=null!==c&&void 0!==c?c.concat([a]):null;return ti(4194308,
    4,yi.bind(null,b,a),c)},useLayoutEffect:function(a,b){return ti(4194308,4,a,b)},useInsertionEffect:function(a,b){return ti(4,2,a,b)},useMemo:function(a,b){var c=ci();b=void 0===b?null:b;a=a();c.memoizedState=[a,b];return a},useReducer:function(a,b,c){var d=ci();b=void 0!==c?c(b):b;d.memoizedState=d.baseState=b;a={pending:null,interleaved:null,lanes:0,dispatch:null,lastRenderedReducer:a,lastRenderedState:b};d.queue=a;a=a.dispatch=Gi.bind(null,N,a);return [d.memoizedState,a]},useRef:function(a){var b=
    ci();a={current:a};return b.memoizedState=a},useState:qi,useDebugValue:Ai,useDeferredValue:function(a){return ci().memoizedState=a},useTransition:function(){var a=qi(!1),b=a[0];a=Ei.bind(null,a[1]);ci().memoizedState=a;return [b,a]},useMutableSource:function(){},useSyncExternalStore:function(a,b,c){var d=N,e=ci();if(I){if(void 0===c)throw Error(p$3(407));c=c();}else {c=b();if(null===R)throw Error(p$3(349));0!==(Rh&30)||ni(d,b,c);}e.memoizedState=c;var f={value:c,getSnapshot:b};e.queue=f;vi(ki.bind(null,d,
    f,a),[a]);d.flags|=2048;li(9,mi.bind(null,d,f,c,b),void 0,null);return c},useId:function(){var a=ci(),b=R.identifierPrefix;if(I){var c=sg;var d=rg;c=(d&~(1<<32-oc(d)-1)).toString(32)+c;b=":"+b+"R"+c;c=Uh++;0<c&&(b+="H"+c.toString(32));b+=":";}else c=Vh++,b=":"+b+"r"+c.toString(32)+":";return a.memoizedState=b},unstable_isNewReconciler:!1},Zh={readContext:Vg,useCallback:Bi,useContext:Vg,useEffect:ji,useImperativeHandle:zi,useInsertionEffect:wi,useLayoutEffect:xi,useMemo:Ci,useReducer:fi,useRef:si,useState:function(){return fi(ei)},
    useDebugValue:Ai,useDeferredValue:function(a){var b=di();return Di(b,O.memoizedState,a)},useTransition:function(){var a=fi(ei)[0],b=di().memoizedState;return [a,b]},useMutableSource:hi,useSyncExternalStore:ii,useId:Fi,unstable_isNewReconciler:!1},$h={readContext:Vg,useCallback:Bi,useContext:Vg,useEffect:ji,useImperativeHandle:zi,useInsertionEffect:wi,useLayoutEffect:xi,useMemo:Ci,useReducer:gi,useRef:si,useState:function(){return gi(ei)},useDebugValue:Ai,useDeferredValue:function(a){var b=di();return null===
    O?b.memoizedState=a:Di(b,O.memoizedState,a)},useTransition:function(){var a=gi(ei)[0],b=di().memoizedState;return [a,b]},useMutableSource:hi,useSyncExternalStore:ii,useId:Fi,unstable_isNewReconciler:!1};function Ki(a,b){try{var c="",d=b;do c+=Pa(d),d=d.return;while(d);var e=c;}catch(f){e="\nError generating stack: "+f.message+"\n"+f.stack;}return {value:a,source:b,stack:e,digest:null}}function Li(a,b,c){return {value:a,source:null,stack:null!=c?c:null,digest:null!=b?b:null}}
    function Mi(a,b){try{console.error(b.value);}catch(c){setTimeout(function(){throw c;});}}var Ni="function"===typeof WeakMap?WeakMap:Map;function Oi(a,b,c){c=ch(-1,c);c.tag=3;c.payload={element:null};var d=b.value;c.callback=function(){Pi||(Pi=!0,Qi=d);Mi(a,b);};return c}
    function Ri(a,b,c){c=ch(-1,c);c.tag=3;var d=a.type.getDerivedStateFromError;if("function"===typeof d){var e=b.value;c.payload=function(){return d(e)};c.callback=function(){Mi(a,b);};}var f=a.stateNode;null!==f&&"function"===typeof f.componentDidCatch&&(c.callback=function(){Mi(a,b);"function"!==typeof d&&(null===Si?Si=new Set([this]):Si.add(this));var c=b.stack;this.componentDidCatch(b.value,{componentStack:null!==c?c:""});});return c}
    function Ti(a,b,c){var d=a.pingCache;if(null===d){d=a.pingCache=new Ni;var e=new Set;d.set(b,e);}else e=d.get(b),void 0===e&&(e=new Set,d.set(b,e));e.has(c)||(e.add(c),a=Ui.bind(null,a,b,c),b.then(a,a));}function Vi(a){do{var b;if(b=13===a.tag)b=a.memoizedState,b=null!==b?null!==b.dehydrated?!0:!1:!0;if(b)return a;a=a.return;}while(null!==a);return null}
    function Wi(a,b,c,d,e){if(0===(a.mode&1))return a===b?a.flags|=65536:(a.flags|=128,c.flags|=131072,c.flags&=-52805,1===c.tag&&(null===c.alternate?c.tag=17:(b=ch(-1,1),b.tag=2,dh(c,b,1))),c.lanes|=1),a;a.flags|=65536;a.lanes=e;return a}var Xi=ua.ReactCurrentOwner,Ug=!1;function Yi(a,b,c,d){b.child=null===a?Ch(b,null,c,d):Bh(b,a.child,c,d);}
    function Zi(a,b,c,d,e){c=c.render;var f=b.ref;Tg(b,e);d=Xh(a,b,c,d,f,e);c=bi();if(null!==a&&!Ug)return b.updateQueue=a.updateQueue,b.flags&=-2053,a.lanes&=~e,$i(a,b,e);I&&c&&vg(b);b.flags|=1;Yi(a,b,d,e);return b.child}
    function aj(a,b,c,d,e){if(null===a){var f=c.type;if("function"===typeof f&&!bj(f)&&void 0===f.defaultProps&&null===c.compare&&void 0===c.defaultProps)return b.tag=15,b.type=f,cj(a,b,f,d,e);a=yh(c.type,null,d,b,b.mode,e);a.ref=b.ref;a.return=b;return b.child=a}f=a.child;if(0===(a.lanes&e)){var g=f.memoizedProps;c=c.compare;c=null!==c?c:Ie;if(c(g,d)&&a.ref===b.ref)return $i(a,b,e)}b.flags|=1;a=wh(f,d);a.ref=b.ref;a.return=b;return b.child=a}
    function cj(a,b,c,d,e){if(null!==a){var f=a.memoizedProps;if(Ie(f,d)&&a.ref===b.ref)if(Ug=!1,b.pendingProps=d=f,0!==(a.lanes&e))0!==(a.flags&131072)&&(Ug=!0);else return b.lanes=a.lanes,$i(a,b,e)}return dj(a,b,c,d,e)}
    function ej(a,b,c){var d=b.pendingProps,e=d.children,f=null!==a?a.memoizedState:null;if("hidden"===d.mode)if(0===(b.mode&1))b.memoizedState={baseLanes:0,cachePool:null,transitions:null},G(fj,gj),gj|=c;else {if(0===(c&1073741824))return a=null!==f?f.baseLanes|c:c,b.lanes=b.childLanes=1073741824,b.memoizedState={baseLanes:a,cachePool:null,transitions:null},b.updateQueue=null,G(fj,gj),gj|=a,null;b.memoizedState={baseLanes:0,cachePool:null,transitions:null};d=null!==f?f.baseLanes:c;G(fj,gj);gj|=d;}else null!==
    f?(d=f.baseLanes|c,b.memoizedState=null):d=c,G(fj,gj),gj|=d;Yi(a,b,e,c);return b.child}function hj(a,b){var c=b.ref;if(null===a&&null!==c||null!==a&&a.ref!==c)b.flags|=512,b.flags|=2097152;}function dj(a,b,c,d,e){var f=Zf(c)?Xf:H.current;f=Yf(b,f);Tg(b,e);c=Xh(a,b,c,d,f,e);d=bi();if(null!==a&&!Ug)return b.updateQueue=a.updateQueue,b.flags&=-2053,a.lanes&=~e,$i(a,b,e);I&&d&&vg(b);b.flags|=1;Yi(a,b,c,e);return b.child}
    function ij(a,b,c,d,e){if(Zf(c)){var f=!0;cg(b);}else f=!1;Tg(b,e);if(null===b.stateNode)jj(a,b),ph(b,c,d),rh(b,c,d,e),d=!0;else if(null===a){var g=b.stateNode,h=b.memoizedProps;g.props=h;var k=g.context,l=c.contextType;"object"===typeof l&&null!==l?l=Vg(l):(l=Zf(c)?Xf:H.current,l=Yf(b,l));var m=c.getDerivedStateFromProps,q="function"===typeof m||"function"===typeof g.getSnapshotBeforeUpdate;q||"function"!==typeof g.UNSAFE_componentWillReceiveProps&&"function"!==typeof g.componentWillReceiveProps||
    (h!==d||k!==l)&&qh(b,g,d,l);$g=!1;var r=b.memoizedState;g.state=r;gh(b,d,g,e);k=b.memoizedState;h!==d||r!==k||Wf.current||$g?("function"===typeof m&&(kh(b,c,m,d),k=b.memoizedState),(h=$g||oh(b,c,h,d,r,k,l))?(q||"function"!==typeof g.UNSAFE_componentWillMount&&"function"!==typeof g.componentWillMount||("function"===typeof g.componentWillMount&&g.componentWillMount(),"function"===typeof g.UNSAFE_componentWillMount&&g.UNSAFE_componentWillMount()),"function"===typeof g.componentDidMount&&(b.flags|=4194308)):
    ("function"===typeof g.componentDidMount&&(b.flags|=4194308),b.memoizedProps=d,b.memoizedState=k),g.props=d,g.state=k,g.context=l,d=h):("function"===typeof g.componentDidMount&&(b.flags|=4194308),d=!1);}else {g=b.stateNode;bh(a,b);h=b.memoizedProps;l=b.type===b.elementType?h:Lg(b.type,h);g.props=l;q=b.pendingProps;r=g.context;k=c.contextType;"object"===typeof k&&null!==k?k=Vg(k):(k=Zf(c)?Xf:H.current,k=Yf(b,k));var y=c.getDerivedStateFromProps;(m="function"===typeof y||"function"===typeof g.getSnapshotBeforeUpdate)||
    "function"!==typeof g.UNSAFE_componentWillReceiveProps&&"function"!==typeof g.componentWillReceiveProps||(h!==q||r!==k)&&qh(b,g,d,k);$g=!1;r=b.memoizedState;g.state=r;gh(b,d,g,e);var n=b.memoizedState;h!==q||r!==n||Wf.current||$g?("function"===typeof y&&(kh(b,c,y,d),n=b.memoizedState),(l=$g||oh(b,c,l,d,r,n,k)||!1)?(m||"function"!==typeof g.UNSAFE_componentWillUpdate&&"function"!==typeof g.componentWillUpdate||("function"===typeof g.componentWillUpdate&&g.componentWillUpdate(d,n,k),"function"===typeof g.UNSAFE_componentWillUpdate&&
    g.UNSAFE_componentWillUpdate(d,n,k)),"function"===typeof g.componentDidUpdate&&(b.flags|=4),"function"===typeof g.getSnapshotBeforeUpdate&&(b.flags|=1024)):("function"!==typeof g.componentDidUpdate||h===a.memoizedProps&&r===a.memoizedState||(b.flags|=4),"function"!==typeof g.getSnapshotBeforeUpdate||h===a.memoizedProps&&r===a.memoizedState||(b.flags|=1024),b.memoizedProps=d,b.memoizedState=n),g.props=d,g.state=n,g.context=k,d=l):("function"!==typeof g.componentDidUpdate||h===a.memoizedProps&&r===
    a.memoizedState||(b.flags|=4),"function"!==typeof g.getSnapshotBeforeUpdate||h===a.memoizedProps&&r===a.memoizedState||(b.flags|=1024),d=!1);}return kj(a,b,c,d,f,e)}
    function kj(a,b,c,d,e,f){hj(a,b);var g=0!==(b.flags&128);if(!d&&!g)return e&&dg(b,c,!1),$i(a,b,f);d=b.stateNode;Xi.current=b;var h=g&&"function"!==typeof c.getDerivedStateFromError?null:d.render();b.flags|=1;null!==a&&g?(b.child=Bh(b,a.child,null,f),b.child=Bh(b,null,h,f)):Yi(a,b,h,f);b.memoizedState=d.state;e&&dg(b,c,!0);return b.child}function lj(a){var b=a.stateNode;b.pendingContext?ag(a,b.pendingContext,b.pendingContext!==b.context):b.context&&ag(a,b.context,!1);Ih(a,b.containerInfo);}
    function mj(a,b,c,d,e){Ig();Jg(e);b.flags|=256;Yi(a,b,c,d);return b.child}var nj={dehydrated:null,treeContext:null,retryLane:0};function oj(a){return {baseLanes:a,cachePool:null,transitions:null}}
    function pj(a,b,c){var d=b.pendingProps,e=M.current,f=!1,g=0!==(b.flags&128),h;(h=g)||(h=null!==a&&null===a.memoizedState?!1:0!==(e&2));if(h)f=!0,b.flags&=-129;else if(null===a||null!==a.memoizedState)e|=1;G(M,e&1);if(null===a){Eg(b);a=b.memoizedState;if(null!==a&&(a=a.dehydrated,null!==a))return 0===(b.mode&1)?b.lanes=1:"$!"===a.data?b.lanes=8:b.lanes=1073741824,null;g=d.children;a=d.fallback;return f?(d=b.mode,f=b.child,g={mode:"hidden",children:g},0===(d&1)&&null!==f?(f.childLanes=0,f.pendingProps=
    g):f=qj(g,d,0,null),a=Ah(a,d,c,null),f.return=b,a.return=b,f.sibling=a,b.child=f,b.child.memoizedState=oj(c),b.memoizedState=nj,a):rj(b,g)}e=a.memoizedState;if(null!==e&&(h=e.dehydrated,null!==h))return sj(a,b,g,d,h,e,c);if(f){f=d.fallback;g=b.mode;e=a.child;h=e.sibling;var k={mode:"hidden",children:d.children};0===(g&1)&&b.child!==e?(d=b.child,d.childLanes=0,d.pendingProps=k,b.deletions=null):(d=wh(e,k),d.subtreeFlags=e.subtreeFlags&14680064);null!==h?f=wh(h,f):(f=Ah(f,g,c,null),f.flags|=2);f.return=
    b;d.return=b;d.sibling=f;b.child=d;d=f;f=b.child;g=a.child.memoizedState;g=null===g?oj(c):{baseLanes:g.baseLanes|c,cachePool:null,transitions:g.transitions};f.memoizedState=g;f.childLanes=a.childLanes&~c;b.memoizedState=nj;return d}f=a.child;a=f.sibling;d=wh(f,{mode:"visible",children:d.children});0===(b.mode&1)&&(d.lanes=c);d.return=b;d.sibling=null;null!==a&&(c=b.deletions,null===c?(b.deletions=[a],b.flags|=16):c.push(a));b.child=d;b.memoizedState=null;return d}
    function rj(a,b){b=qj({mode:"visible",children:b},a.mode,0,null);b.return=a;return a.child=b}function tj(a,b,c,d){null!==d&&Jg(d);Bh(b,a.child,null,c);a=rj(b,b.pendingProps.children);a.flags|=2;b.memoizedState=null;return a}
    function sj(a,b,c,d,e,f,g){if(c){if(b.flags&256)return b.flags&=-257,d=Li(Error(p$3(422))),tj(a,b,g,d);if(null!==b.memoizedState)return b.child=a.child,b.flags|=128,null;f=d.fallback;e=b.mode;d=qj({mode:"visible",children:d.children},e,0,null);f=Ah(f,e,g,null);f.flags|=2;d.return=b;f.return=b;d.sibling=f;b.child=d;0!==(b.mode&1)&&Bh(b,a.child,null,g);b.child.memoizedState=oj(g);b.memoizedState=nj;return f}if(0===(b.mode&1))return tj(a,b,g,null);if("$!"===e.data){d=e.nextSibling&&e.nextSibling.dataset;
    if(d)var h=d.dgst;d=h;f=Error(p$3(419));d=Li(f,d,void 0);return tj(a,b,g,d)}h=0!==(g&a.childLanes);if(Ug||h){d=R;if(null!==d){switch(g&-g){case 4:e=2;break;case 16:e=8;break;case 64:case 128:case 256:case 512:case 1024:case 2048:case 4096:case 8192:case 16384:case 32768:case 65536:case 131072:case 262144:case 524288:case 1048576:case 2097152:case 4194304:case 8388608:case 16777216:case 33554432:case 67108864:e=32;break;case 536870912:e=268435456;break;default:e=0;}e=0!==(e&(d.suspendedLanes|g))?0:e;
    0!==e&&e!==f.retryLane&&(f.retryLane=e,Zg(a,e),mh(d,a,e,-1));}uj();d=Li(Error(p$3(421)));return tj(a,b,g,d)}if("$?"===e.data)return b.flags|=128,b.child=a.child,b=vj.bind(null,a),e._reactRetry=b,null;a=f.treeContext;yg=Lf(e.nextSibling);xg=b;I=!0;zg=null;null!==a&&(og[pg++]=rg,og[pg++]=sg,og[pg++]=qg,rg=a.id,sg=a.overflow,qg=b);b=rj(b,d.children);b.flags|=4096;return b}function wj(a,b,c){a.lanes|=b;var d=a.alternate;null!==d&&(d.lanes|=b);Sg(a.return,b,c);}
    function xj(a,b,c,d,e){var f=a.memoizedState;null===f?a.memoizedState={isBackwards:b,rendering:null,renderingStartTime:0,last:d,tail:c,tailMode:e}:(f.isBackwards=b,f.rendering=null,f.renderingStartTime=0,f.last=d,f.tail=c,f.tailMode=e);}
    function yj(a,b,c){var d=b.pendingProps,e=d.revealOrder,f=d.tail;Yi(a,b,d.children,c);d=M.current;if(0!==(d&2))d=d&1|2,b.flags|=128;else {if(null!==a&&0!==(a.flags&128))a:for(a=b.child;null!==a;){if(13===a.tag)null!==a.memoizedState&&wj(a,c,b);else if(19===a.tag)wj(a,c,b);else if(null!==a.child){a.child.return=a;a=a.child;continue}if(a===b)break a;for(;null===a.sibling;){if(null===a.return||a.return===b)break a;a=a.return;}a.sibling.return=a.return;a=a.sibling;}d&=1;}G(M,d);if(0===(b.mode&1))b.memoizedState=
    null;else switch(e){case "forwards":c=b.child;for(e=null;null!==c;)a=c.alternate,null!==a&&null===Mh(a)&&(e=c),c=c.sibling;c=e;null===c?(e=b.child,b.child=null):(e=c.sibling,c.sibling=null);xj(b,!1,e,c,f);break;case "backwards":c=null;e=b.child;for(b.child=null;null!==e;){a=e.alternate;if(null!==a&&null===Mh(a)){b.child=e;break}a=e.sibling;e.sibling=c;c=e;e=a;}xj(b,!0,c,null,f);break;case "together":xj(b,!1,null,null,void 0);break;default:b.memoizedState=null;}return b.child}
    function jj(a,b){0===(b.mode&1)&&null!==a&&(a.alternate=null,b.alternate=null,b.flags|=2);}function $i(a,b,c){null!==a&&(b.dependencies=a.dependencies);hh|=b.lanes;if(0===(c&b.childLanes))return null;if(null!==a&&b.child!==a.child)throw Error(p$3(153));if(null!==b.child){a=b.child;c=wh(a,a.pendingProps);b.child=c;for(c.return=b;null!==a.sibling;)a=a.sibling,c=c.sibling=wh(a,a.pendingProps),c.return=b;c.sibling=null;}return b.child}
    function zj(a,b,c){switch(b.tag){case 3:lj(b);Ig();break;case 5:Kh(b);break;case 1:Zf(b.type)&&cg(b);break;case 4:Ih(b,b.stateNode.containerInfo);break;case 10:var d=b.type._context,e=b.memoizedProps.value;G(Mg,d._currentValue);d._currentValue=e;break;case 13:d=b.memoizedState;if(null!==d){if(null!==d.dehydrated)return G(M,M.current&1),b.flags|=128,null;if(0!==(c&b.child.childLanes))return pj(a,b,c);G(M,M.current&1);a=$i(a,b,c);return null!==a?a.sibling:null}G(M,M.current&1);break;case 19:d=0!==(c&
    b.childLanes);if(0!==(a.flags&128)){if(d)return yj(a,b,c);b.flags|=128;}e=b.memoizedState;null!==e&&(e.rendering=null,e.tail=null,e.lastEffect=null);G(M,M.current);if(d)break;else return null;case 22:case 23:return b.lanes=0,ej(a,b,c)}return $i(a,b,c)}var Aj,Bj,Cj,Dj;
    Aj=function(a,b){for(var c=b.child;null!==c;){if(5===c.tag||6===c.tag)a.appendChild(c.stateNode);else if(4!==c.tag&&null!==c.child){c.child.return=c;c=c.child;continue}if(c===b)break;for(;null===c.sibling;){if(null===c.return||c.return===b)return;c=c.return;}c.sibling.return=c.return;c=c.sibling;}};Bj=function(){};
    Cj=function(a,b,c,d){var e=a.memoizedProps;if(e!==d){a=b.stateNode;Hh(Eh.current);var f=null;switch(c){case "input":e=Ya(a,e);d=Ya(a,d);f=[];break;case "select":e=A$1({},e,{value:void 0});d=A$1({},d,{value:void 0});f=[];break;case "textarea":e=gb(a,e);d=gb(a,d);f=[];break;default:"function"!==typeof e.onClick&&"function"===typeof d.onClick&&(a.onclick=Bf);}ub(c,d);var g;c=null;for(l in e)if(!d.hasOwnProperty(l)&&e.hasOwnProperty(l)&&null!=e[l])if("style"===l){var h=e[l];for(g in h)h.hasOwnProperty(g)&&
    (c||(c={}),c[g]="");}else "dangerouslySetInnerHTML"!==l&&"children"!==l&&"suppressContentEditableWarning"!==l&&"suppressHydrationWarning"!==l&&"autoFocus"!==l&&(ea.hasOwnProperty(l)?f||(f=[]):(f=f||[]).push(l,null));for(l in d){var k=d[l];h=null!=e?e[l]:void 0;if(d.hasOwnProperty(l)&&k!==h&&(null!=k||null!=h))if("style"===l)if(h){for(g in h)!h.hasOwnProperty(g)||k&&k.hasOwnProperty(g)||(c||(c={}),c[g]="");for(g in k)k.hasOwnProperty(g)&&h[g]!==k[g]&&(c||(c={}),c[g]=k[g]);}else c||(f||(f=[]),f.push(l,
    c)),c=k;else "dangerouslySetInnerHTML"===l?(k=k?k.__html:void 0,h=h?h.__html:void 0,null!=k&&h!==k&&(f=f||[]).push(l,k)):"children"===l?"string"!==typeof k&&"number"!==typeof k||(f=f||[]).push(l,""+k):"suppressContentEditableWarning"!==l&&"suppressHydrationWarning"!==l&&(ea.hasOwnProperty(l)?(null!=k&&"onScroll"===l&&D("scroll",a),f||h===k||(f=[])):(f=f||[]).push(l,k));}c&&(f=f||[]).push("style",c);var l=f;if(b.updateQueue=l)b.flags|=4;}};Dj=function(a,b,c,d){c!==d&&(b.flags|=4);};
    function Ej(a,b){if(!I)switch(a.tailMode){case "hidden":b=a.tail;for(var c=null;null!==b;)null!==b.alternate&&(c=b),b=b.sibling;null===c?a.tail=null:c.sibling=null;break;case "collapsed":c=a.tail;for(var d=null;null!==c;)null!==c.alternate&&(d=c),c=c.sibling;null===d?b||null===a.tail?a.tail=null:a.tail.sibling=null:d.sibling=null;}}
    function S(a){var b=null!==a.alternate&&a.alternate.child===a.child,c=0,d=0;if(b)for(var e=a.child;null!==e;)c|=e.lanes|e.childLanes,d|=e.subtreeFlags&14680064,d|=e.flags&14680064,e.return=a,e=e.sibling;else for(e=a.child;null!==e;)c|=e.lanes|e.childLanes,d|=e.subtreeFlags,d|=e.flags,e.return=a,e=e.sibling;a.subtreeFlags|=d;a.childLanes=c;return b}
    function Fj(a,b,c){var d=b.pendingProps;wg(b);switch(b.tag){case 2:case 16:case 15:case 0:case 11:case 7:case 8:case 12:case 9:case 14:return S(b),null;case 1:return Zf(b.type)&&$f(),S(b),null;case 3:d=b.stateNode;Jh();E(Wf);E(H);Oh();d.pendingContext&&(d.context=d.pendingContext,d.pendingContext=null);if(null===a||null===a.child)Gg(b)?b.flags|=4:null===a||a.memoizedState.isDehydrated&&0===(b.flags&256)||(b.flags|=1024,null!==zg&&(Gj(zg),zg=null));Bj(a,b);S(b);return null;case 5:Lh(b);var e=Hh(Gh.current);
    c=b.type;if(null!==a&&null!=b.stateNode)Cj(a,b,c,d,e),a.ref!==b.ref&&(b.flags|=512,b.flags|=2097152);else {if(!d){if(null===b.stateNode)throw Error(p$3(166));S(b);return null}a=Hh(Eh.current);if(Gg(b)){d=b.stateNode;c=b.type;var f=b.memoizedProps;d[Of]=b;d[Pf]=f;a=0!==(b.mode&1);switch(c){case "dialog":D("cancel",d);D("close",d);break;case "iframe":case "object":case "embed":D("load",d);break;case "video":case "audio":for(e=0;e<lf.length;e++)D(lf[e],d);break;case "source":D("error",d);break;case "img":case "image":case "link":D("error",
    d);D("load",d);break;case "details":D("toggle",d);break;case "input":Za(d,f);D("invalid",d);break;case "select":d._wrapperState={wasMultiple:!!f.multiple};D("invalid",d);break;case "textarea":hb(d,f),D("invalid",d);}ub(c,f);e=null;for(var g in f)if(f.hasOwnProperty(g)){var h=f[g];"children"===g?"string"===typeof h?d.textContent!==h&&(!0!==f.suppressHydrationWarning&&Af(d.textContent,h,a),e=["children",h]):"number"===typeof h&&d.textContent!==""+h&&(!0!==f.suppressHydrationWarning&&Af(d.textContent,
    h,a),e=["children",""+h]):ea.hasOwnProperty(g)&&null!=h&&"onScroll"===g&&D("scroll",d);}switch(c){case "input":Va(d);db(d,f,!0);break;case "textarea":Va(d);jb(d);break;case "select":case "option":break;default:"function"===typeof f.onClick&&(d.onclick=Bf);}d=e;b.updateQueue=d;null!==d&&(b.flags|=4);}else {g=9===e.nodeType?e:e.ownerDocument;"http://www.w3.org/1999/xhtml"===a&&(a=kb(c));"http://www.w3.org/1999/xhtml"===a?"script"===c?(a=g.createElement("div"),a.innerHTML="<script>\x3c/script>",a=a.removeChild(a.firstChild)):
    "string"===typeof d.is?a=g.createElement(c,{is:d.is}):(a=g.createElement(c),"select"===c&&(g=a,d.multiple?g.multiple=!0:d.size&&(g.size=d.size))):a=g.createElementNS(a,c);a[Of]=b;a[Pf]=d;Aj(a,b,!1,!1);b.stateNode=a;a:{g=vb(c,d);switch(c){case "dialog":D("cancel",a);D("close",a);e=d;break;case "iframe":case "object":case "embed":D("load",a);e=d;break;case "video":case "audio":for(e=0;e<lf.length;e++)D(lf[e],a);e=d;break;case "source":D("error",a);e=d;break;case "img":case "image":case "link":D("error",
    a);D("load",a);e=d;break;case "details":D("toggle",a);e=d;break;case "input":Za(a,d);e=Ya(a,d);D("invalid",a);break;case "option":e=d;break;case "select":a._wrapperState={wasMultiple:!!d.multiple};e=A$1({},d,{value:void 0});D("invalid",a);break;case "textarea":hb(a,d);e=gb(a,d);D("invalid",a);break;default:e=d;}ub(c,e);h=e;for(f in h)if(h.hasOwnProperty(f)){var k=h[f];"style"===f?sb(a,k):"dangerouslySetInnerHTML"===f?(k=k?k.__html:void 0,null!=k&&nb(a,k)):"children"===f?"string"===typeof k?("textarea"!==
    c||""!==k)&&ob(a,k):"number"===typeof k&&ob(a,""+k):"suppressContentEditableWarning"!==f&&"suppressHydrationWarning"!==f&&"autoFocus"!==f&&(ea.hasOwnProperty(f)?null!=k&&"onScroll"===f&&D("scroll",a):null!=k&&ta(a,f,k,g));}switch(c){case "input":Va(a);db(a,d,!1);break;case "textarea":Va(a);jb(a);break;case "option":null!=d.value&&a.setAttribute("value",""+Sa(d.value));break;case "select":a.multiple=!!d.multiple;f=d.value;null!=f?fb(a,!!d.multiple,f,!1):null!=d.defaultValue&&fb(a,!!d.multiple,d.defaultValue,
    !0);break;default:"function"===typeof e.onClick&&(a.onclick=Bf);}switch(c){case "button":case "input":case "select":case "textarea":d=!!d.autoFocus;break a;case "img":d=!0;break a;default:d=!1;}}d&&(b.flags|=4);}null!==b.ref&&(b.flags|=512,b.flags|=2097152);}S(b);return null;case 6:if(a&&null!=b.stateNode)Dj(a,b,a.memoizedProps,d);else {if("string"!==typeof d&&null===b.stateNode)throw Error(p$3(166));c=Hh(Gh.current);Hh(Eh.current);if(Gg(b)){d=b.stateNode;c=b.memoizedProps;d[Of]=b;if(f=d.nodeValue!==c)if(a=
    xg,null!==a)switch(a.tag){case 3:Af(d.nodeValue,c,0!==(a.mode&1));break;case 5:!0!==a.memoizedProps.suppressHydrationWarning&&Af(d.nodeValue,c,0!==(a.mode&1));}f&&(b.flags|=4);}else d=(9===c.nodeType?c:c.ownerDocument).createTextNode(d),d[Of]=b,b.stateNode=d;}S(b);return null;case 13:E(M);d=b.memoizedState;if(null===a||null!==a.memoizedState&&null!==a.memoizedState.dehydrated){if(I&&null!==yg&&0!==(b.mode&1)&&0===(b.flags&128))Hg(),Ig(),b.flags|=98560,f=!1;else if(f=Gg(b),null!==d&&null!==d.dehydrated){if(null===
    a){if(!f)throw Error(p$3(318));f=b.memoizedState;f=null!==f?f.dehydrated:null;if(!f)throw Error(p$3(317));f[Of]=b;}else Ig(),0===(b.flags&128)&&(b.memoizedState=null),b.flags|=4;S(b);f=!1;}else null!==zg&&(Gj(zg),zg=null),f=!0;if(!f)return b.flags&65536?b:null}if(0!==(b.flags&128))return b.lanes=c,b;d=null!==d;d!==(null!==a&&null!==a.memoizedState)&&d&&(b.child.flags|=8192,0!==(b.mode&1)&&(null===a||0!==(M.current&1)?0===T&&(T=3):uj()));null!==b.updateQueue&&(b.flags|=4);S(b);return null;case 4:return Jh(),
    Bj(a,b),null===a&&sf(b.stateNode.containerInfo),S(b),null;case 10:return Rg(b.type._context),S(b),null;case 17:return Zf(b.type)&&$f(),S(b),null;case 19:E(M);f=b.memoizedState;if(null===f)return S(b),null;d=0!==(b.flags&128);g=f.rendering;if(null===g)if(d)Ej(f,!1);else {if(0!==T||null!==a&&0!==(a.flags&128))for(a=b.child;null!==a;){g=Mh(a);if(null!==g){b.flags|=128;Ej(f,!1);d=g.updateQueue;null!==d&&(b.updateQueue=d,b.flags|=4);b.subtreeFlags=0;d=c;for(c=b.child;null!==c;)f=c,a=d,f.flags&=14680066,
    g=f.alternate,null===g?(f.childLanes=0,f.lanes=a,f.child=null,f.subtreeFlags=0,f.memoizedProps=null,f.memoizedState=null,f.updateQueue=null,f.dependencies=null,f.stateNode=null):(f.childLanes=g.childLanes,f.lanes=g.lanes,f.child=g.child,f.subtreeFlags=0,f.deletions=null,f.memoizedProps=g.memoizedProps,f.memoizedState=g.memoizedState,f.updateQueue=g.updateQueue,f.type=g.type,a=g.dependencies,f.dependencies=null===a?null:{lanes:a.lanes,firstContext:a.firstContext}),c=c.sibling;G(M,M.current&1|2);return b.child}a=
    a.sibling;}null!==f.tail&&B()>Hj&&(b.flags|=128,d=!0,Ej(f,!1),b.lanes=4194304);}else {if(!d)if(a=Mh(g),null!==a){if(b.flags|=128,d=!0,c=a.updateQueue,null!==c&&(b.updateQueue=c,b.flags|=4),Ej(f,!0),null===f.tail&&"hidden"===f.tailMode&&!g.alternate&&!I)return S(b),null}else 2*B()-f.renderingStartTime>Hj&&1073741824!==c&&(b.flags|=128,d=!0,Ej(f,!1),b.lanes=4194304);f.isBackwards?(g.sibling=b.child,b.child=g):(c=f.last,null!==c?c.sibling=g:b.child=g,f.last=g);}if(null!==f.tail)return b=f.tail,f.rendering=
    b,f.tail=b.sibling,f.renderingStartTime=B(),b.sibling=null,c=M.current,G(M,d?c&1|2:c&1),b;S(b);return null;case 22:case 23:return Ij(),d=null!==b.memoizedState,null!==a&&null!==a.memoizedState!==d&&(b.flags|=8192),d&&0!==(b.mode&1)?0!==(gj&1073741824)&&(S(b),b.subtreeFlags&6&&(b.flags|=8192)):S(b),null;case 24:return null;case 25:return null}throw Error(p$3(156,b.tag));}
    function Jj(a,b){wg(b);switch(b.tag){case 1:return Zf(b.type)&&$f(),a=b.flags,a&65536?(b.flags=a&-65537|128,b):null;case 3:return Jh(),E(Wf),E(H),Oh(),a=b.flags,0!==(a&65536)&&0===(a&128)?(b.flags=a&-65537|128,b):null;case 5:return Lh(b),null;case 13:E(M);a=b.memoizedState;if(null!==a&&null!==a.dehydrated){if(null===b.alternate)throw Error(p$3(340));Ig();}a=b.flags;return a&65536?(b.flags=a&-65537|128,b):null;case 19:return E(M),null;case 4:return Jh(),null;case 10:return Rg(b.type._context),null;case 22:case 23:return Ij(),
    null;case 24:return null;default:return null}}var Kj=!1,U=!1,Lj="function"===typeof WeakSet?WeakSet:Set,V=null;function Mj(a,b){var c=a.ref;if(null!==c)if("function"===typeof c)try{c(null);}catch(d){W(a,b,d);}else c.current=null;}function Nj(a,b,c){try{c();}catch(d){W(a,b,d);}}var Oj=!1;
    function Pj(a,b){Cf=dd;a=Me();if(Ne(a)){if("selectionStart"in a)var c={start:a.selectionStart,end:a.selectionEnd};else a:{c=(c=a.ownerDocument)&&c.defaultView||window;var d=c.getSelection&&c.getSelection();if(d&&0!==d.rangeCount){c=d.anchorNode;var e=d.anchorOffset,f=d.focusNode;d=d.focusOffset;try{c.nodeType,f.nodeType;}catch(F){c=null;break a}var g=0,h=-1,k=-1,l=0,m=0,q=a,r=null;b:for(;;){for(var y;;){q!==c||0!==e&&3!==q.nodeType||(h=g+e);q!==f||0!==d&&3!==q.nodeType||(k=g+d);3===q.nodeType&&(g+=
    q.nodeValue.length);if(null===(y=q.firstChild))break;r=q;q=y;}for(;;){if(q===a)break b;r===c&&++l===e&&(h=g);r===f&&++m===d&&(k=g);if(null!==(y=q.nextSibling))break;q=r;r=q.parentNode;}q=y;}c=-1===h||-1===k?null:{start:h,end:k};}else c=null;}c=c||{start:0,end:0};}else c=null;Df={focusedElem:a,selectionRange:c};dd=!1;for(V=b;null!==V;)if(b=V,a=b.child,0!==(b.subtreeFlags&1028)&&null!==a)a.return=b,V=a;else for(;null!==V;){b=V;try{var n=b.alternate;if(0!==(b.flags&1024))switch(b.tag){case 0:case 11:case 15:break;
    case 1:if(null!==n){var t=n.memoizedProps,J=n.memoizedState,x=b.stateNode,w=x.getSnapshotBeforeUpdate(b.elementType===b.type?t:Lg(b.type,t),J);x.__reactInternalSnapshotBeforeUpdate=w;}break;case 3:var u=b.stateNode.containerInfo;1===u.nodeType?u.textContent="":9===u.nodeType&&u.documentElement&&u.removeChild(u.documentElement);break;case 5:case 6:case 4:case 17:break;default:throw Error(p$3(163));}}catch(F){W(b,b.return,F);}a=b.sibling;if(null!==a){a.return=b.return;V=a;break}V=b.return;}n=Oj;Oj=!1;return n}
    function Qj(a,b,c){var d=b.updateQueue;d=null!==d?d.lastEffect:null;if(null!==d){var e=d=d.next;do{if((e.tag&a)===a){var f=e.destroy;e.destroy=void 0;void 0!==f&&Nj(b,c,f);}e=e.next;}while(e!==d)}}function Rj(a,b){b=b.updateQueue;b=null!==b?b.lastEffect:null;if(null!==b){var c=b=b.next;do{if((c.tag&a)===a){var d=c.create;c.destroy=d();}c=c.next;}while(c!==b)}}function Sj(a){var b=a.ref;if(null!==b){var c=a.stateNode;switch(a.tag){case 5:a=c;break;default:a=c;}"function"===typeof b?b(a):b.current=a;}}
    function Tj(a){var b=a.alternate;null!==b&&(a.alternate=null,Tj(b));a.child=null;a.deletions=null;a.sibling=null;5===a.tag&&(b=a.stateNode,null!==b&&(delete b[Of],delete b[Pf],delete b[of],delete b[Qf],delete b[Rf]));a.stateNode=null;a.return=null;a.dependencies=null;a.memoizedProps=null;a.memoizedState=null;a.pendingProps=null;a.stateNode=null;a.updateQueue=null;}function Uj(a){return 5===a.tag||3===a.tag||4===a.tag}
    function Vj(a){a:for(;;){for(;null===a.sibling;){if(null===a.return||Uj(a.return))return null;a=a.return;}a.sibling.return=a.return;for(a=a.sibling;5!==a.tag&&6!==a.tag&&18!==a.tag;){if(a.flags&2)continue a;if(null===a.child||4===a.tag)continue a;else a.child.return=a,a=a.child;}if(!(a.flags&2))return a.stateNode}}
    function Wj(a,b,c){var d=a.tag;if(5===d||6===d)a=a.stateNode,b?8===c.nodeType?c.parentNode.insertBefore(a,b):c.insertBefore(a,b):(8===c.nodeType?(b=c.parentNode,b.insertBefore(a,c)):(b=c,b.appendChild(a)),c=c._reactRootContainer,null!==c&&void 0!==c||null!==b.onclick||(b.onclick=Bf));else if(4!==d&&(a=a.child,null!==a))for(Wj(a,b,c),a=a.sibling;null!==a;)Wj(a,b,c),a=a.sibling;}
    function Xj(a,b,c){var d=a.tag;if(5===d||6===d)a=a.stateNode,b?c.insertBefore(a,b):c.appendChild(a);else if(4!==d&&(a=a.child,null!==a))for(Xj(a,b,c),a=a.sibling;null!==a;)Xj(a,b,c),a=a.sibling;}var X=null,Yj=!1;function Zj(a,b,c){for(c=c.child;null!==c;)ak(a,b,c),c=c.sibling;}
    function ak(a,b,c){if(lc&&"function"===typeof lc.onCommitFiberUnmount)try{lc.onCommitFiberUnmount(kc,c);}catch(h){}switch(c.tag){case 5:U||Mj(c,b);case 6:var d=X,e=Yj;X=null;Zj(a,b,c);X=d;Yj=e;null!==X&&(Yj?(a=X,c=c.stateNode,8===a.nodeType?a.parentNode.removeChild(c):a.removeChild(c)):X.removeChild(c.stateNode));break;case 18:null!==X&&(Yj?(a=X,c=c.stateNode,8===a.nodeType?Kf(a.parentNode,c):1===a.nodeType&&Kf(a,c),bd(a)):Kf(X,c.stateNode));break;case 4:d=X;e=Yj;X=c.stateNode.containerInfo;Yj=!0;
    Zj(a,b,c);X=d;Yj=e;break;case 0:case 11:case 14:case 15:if(!U&&(d=c.updateQueue,null!==d&&(d=d.lastEffect,null!==d))){e=d=d.next;do{var f=e,g=f.destroy;f=f.tag;void 0!==g&&(0!==(f&2)?Nj(c,b,g):0!==(f&4)&&Nj(c,b,g));e=e.next;}while(e!==d)}Zj(a,b,c);break;case 1:if(!U&&(Mj(c,b),d=c.stateNode,"function"===typeof d.componentWillUnmount))try{d.props=c.memoizedProps,d.state=c.memoizedState,d.componentWillUnmount();}catch(h){W(c,b,h);}Zj(a,b,c);break;case 21:Zj(a,b,c);break;case 22:c.mode&1?(U=(d=U)||null!==
    c.memoizedState,Zj(a,b,c),U=d):Zj(a,b,c);break;default:Zj(a,b,c);}}function bk(a){var b=a.updateQueue;if(null!==b){a.updateQueue=null;var c=a.stateNode;null===c&&(c=a.stateNode=new Lj);b.forEach(function(b){var d=ck.bind(null,a,b);c.has(b)||(c.add(b),b.then(d,d));});}}
    function dk(a,b){var c=b.deletions;if(null!==c)for(var d=0;d<c.length;d++){var e=c[d];try{var f=a,g=b,h=g;a:for(;null!==h;){switch(h.tag){case 5:X=h.stateNode;Yj=!1;break a;case 3:X=h.stateNode.containerInfo;Yj=!0;break a;case 4:X=h.stateNode.containerInfo;Yj=!0;break a}h=h.return;}if(null===X)throw Error(p$3(160));ak(f,g,e);X=null;Yj=!1;var k=e.alternate;null!==k&&(k.return=null);e.return=null;}catch(l){W(e,b,l);}}if(b.subtreeFlags&12854)for(b=b.child;null!==b;)ek(b,a),b=b.sibling;}
    function ek(a,b){var c=a.alternate,d=a.flags;switch(a.tag){case 0:case 11:case 14:case 15:dk(b,a);fk(a);if(d&4){try{Qj(3,a,a.return),Rj(3,a);}catch(t){W(a,a.return,t);}try{Qj(5,a,a.return);}catch(t){W(a,a.return,t);}}break;case 1:dk(b,a);fk(a);d&512&&null!==c&&Mj(c,c.return);break;case 5:dk(b,a);fk(a);d&512&&null!==c&&Mj(c,c.return);if(a.flags&32){var e=a.stateNode;try{ob(e,"");}catch(t){W(a,a.return,t);}}if(d&4&&(e=a.stateNode,null!=e)){var f=a.memoizedProps,g=null!==c?c.memoizedProps:f,h=a.type,k=a.updateQueue;
    a.updateQueue=null;if(null!==k)try{"input"===h&&"radio"===f.type&&null!=f.name&&ab(e,f);vb(h,g);var l=vb(h,f);for(g=0;g<k.length;g+=2){var m=k[g],q=k[g+1];"style"===m?sb(e,q):"dangerouslySetInnerHTML"===m?nb(e,q):"children"===m?ob(e,q):ta(e,m,q,l);}switch(h){case "input":bb(e,f);break;case "textarea":ib(e,f);break;case "select":var r=e._wrapperState.wasMultiple;e._wrapperState.wasMultiple=!!f.multiple;var y=f.value;null!=y?fb(e,!!f.multiple,y,!1):r!==!!f.multiple&&(null!=f.defaultValue?fb(e,!!f.multiple,
    f.defaultValue,!0):fb(e,!!f.multiple,f.multiple?[]:"",!1));}e[Pf]=f;}catch(t){W(a,a.return,t);}}break;case 6:dk(b,a);fk(a);if(d&4){if(null===a.stateNode)throw Error(p$3(162));e=a.stateNode;f=a.memoizedProps;try{e.nodeValue=f;}catch(t){W(a,a.return,t);}}break;case 3:dk(b,a);fk(a);if(d&4&&null!==c&&c.memoizedState.isDehydrated)try{bd(b.containerInfo);}catch(t){W(a,a.return,t);}break;case 4:dk(b,a);fk(a);break;case 13:dk(b,a);fk(a);e=a.child;e.flags&8192&&(f=null!==e.memoizedState,e.stateNode.isHidden=f,!f||
    null!==e.alternate&&null!==e.alternate.memoizedState||(gk=B()));d&4&&bk(a);break;case 22:m=null!==c&&null!==c.memoizedState;a.mode&1?(U=(l=U)||m,dk(b,a),U=l):dk(b,a);fk(a);if(d&8192){l=null!==a.memoizedState;if((a.stateNode.isHidden=l)&&!m&&0!==(a.mode&1))for(V=a,m=a.child;null!==m;){for(q=V=m;null!==V;){r=V;y=r.child;switch(r.tag){case 0:case 11:case 14:case 15:Qj(4,r,r.return);break;case 1:Mj(r,r.return);var n=r.stateNode;if("function"===typeof n.componentWillUnmount){d=r;c=r.return;try{b=d,n.props=
    b.memoizedProps,n.state=b.memoizedState,n.componentWillUnmount();}catch(t){W(d,c,t);}}break;case 5:Mj(r,r.return);break;case 22:if(null!==r.memoizedState){hk(q);continue}}null!==y?(y.return=r,V=y):hk(q);}m=m.sibling;}a:for(m=null,q=a;;){if(5===q.tag){if(null===m){m=q;try{e=q.stateNode,l?(f=e.style,"function"===typeof f.setProperty?f.setProperty("display","none","important"):f.display="none"):(h=q.stateNode,k=q.memoizedProps.style,g=void 0!==k&&null!==k&&k.hasOwnProperty("display")?k.display:null,h.style.display=
    rb$1("display",g));}catch(t){W(a,a.return,t);}}}else if(6===q.tag){if(null===m)try{q.stateNode.nodeValue=l?"":q.memoizedProps;}catch(t){W(a,a.return,t);}}else if((22!==q.tag&&23!==q.tag||null===q.memoizedState||q===a)&&null!==q.child){q.child.return=q;q=q.child;continue}if(q===a)break a;for(;null===q.sibling;){if(null===q.return||q.return===a)break a;m===q&&(m=null);q=q.return;}m===q&&(m=null);q.sibling.return=q.return;q=q.sibling;}}break;case 19:dk(b,a);fk(a);d&4&&bk(a);break;case 21:break;default:dk(b,
    a),fk(a);}}function fk(a){var b=a.flags;if(b&2){try{a:{for(var c=a.return;null!==c;){if(Uj(c)){var d=c;break a}c=c.return;}throw Error(p$3(160));}switch(d.tag){case 5:var e=d.stateNode;d.flags&32&&(ob(e,""),d.flags&=-33);var f=Vj(a);Xj(a,f,e);break;case 3:case 4:var g=d.stateNode.containerInfo,h=Vj(a);Wj(a,h,g);break;default:throw Error(p$3(161));}}catch(k){W(a,a.return,k);}a.flags&=-3;}b&4096&&(a.flags&=-4097);}function ik(a,b,c){V=a;jk(a);}
    function jk(a,b,c){for(var d=0!==(a.mode&1);null!==V;){var e=V,f=e.child;if(22===e.tag&&d){var g=null!==e.memoizedState||Kj;if(!g){var h=e.alternate,k=null!==h&&null!==h.memoizedState||U;h=Kj;var l=U;Kj=g;if((U=k)&&!l)for(V=e;null!==V;)g=V,k=g.child,22===g.tag&&null!==g.memoizedState?kk(e):null!==k?(k.return=g,V=k):kk(e);for(;null!==f;)V=f,jk(f),f=f.sibling;V=e;Kj=h;U=l;}lk(a);}else 0!==(e.subtreeFlags&8772)&&null!==f?(f.return=e,V=f):lk(a);}}
    function lk(a){for(;null!==V;){var b=V;if(0!==(b.flags&8772)){var c=b.alternate;try{if(0!==(b.flags&8772))switch(b.tag){case 0:case 11:case 15:U||Rj(5,b);break;case 1:var d=b.stateNode;if(b.flags&4&&!U)if(null===c)d.componentDidMount();else {var e=b.elementType===b.type?c.memoizedProps:Lg(b.type,c.memoizedProps);d.componentDidUpdate(e,c.memoizedState,d.__reactInternalSnapshotBeforeUpdate);}var f=b.updateQueue;null!==f&&ih(b,f,d);break;case 3:var g=b.updateQueue;if(null!==g){c=null;if(null!==b.child)switch(b.child.tag){case 5:c=
    b.child.stateNode;break;case 1:c=b.child.stateNode;}ih(b,g,c);}break;case 5:var h=b.stateNode;if(null===c&&b.flags&4){c=h;var k=b.memoizedProps;switch(b.type){case "button":case "input":case "select":case "textarea":k.autoFocus&&c.focus();break;case "img":k.src&&(c.src=k.src);}}break;case 6:break;case 4:break;case 12:break;case 13:if(null===b.memoizedState){var l=b.alternate;if(null!==l){var m=l.memoizedState;if(null!==m){var q=m.dehydrated;null!==q&&bd(q);}}}break;case 19:case 17:case 21:case 22:case 23:case 25:break;
    default:throw Error(p$3(163));}U||b.flags&512&&Sj(b);}catch(r){W(b,b.return,r);}}if(b===a){V=null;break}c=b.sibling;if(null!==c){c.return=b.return;V=c;break}V=b.return;}}function hk(a){for(;null!==V;){var b=V;if(b===a){V=null;break}var c=b.sibling;if(null!==c){c.return=b.return;V=c;break}V=b.return;}}
    function kk(a){for(;null!==V;){var b=V;try{switch(b.tag){case 0:case 11:case 15:var c=b.return;try{Rj(4,b);}catch(k){W(b,c,k);}break;case 1:var d=b.stateNode;if("function"===typeof d.componentDidMount){var e=b.return;try{d.componentDidMount();}catch(k){W(b,e,k);}}var f=b.return;try{Sj(b);}catch(k){W(b,f,k);}break;case 5:var g=b.return;try{Sj(b);}catch(k){W(b,g,k);}}}catch(k){W(b,b.return,k);}if(b===a){V=null;break}var h=b.sibling;if(null!==h){h.return=b.return;V=h;break}V=b.return;}}
    var mk=Math.ceil,nk=ua.ReactCurrentDispatcher,ok=ua.ReactCurrentOwner,pk=ua.ReactCurrentBatchConfig,K=0,R=null,Y=null,Z=0,gj=0,fj=Uf(0),T=0,qk=null,hh=0,rk=0,sk=0,tk=null,uk=null,gk=0,Hj=Infinity,vk=null,Pi=!1,Qi=null,Si=null,wk=!1,xk=null,yk=0,zk=0,Ak=null,Bk=-1,Ck=0;function L(){return 0!==(K&6)?B():-1!==Bk?Bk:Bk=B()}
    function lh(a){if(0===(a.mode&1))return 1;if(0!==(K&2)&&0!==Z)return Z&-Z;if(null!==Kg.transition)return 0===Ck&&(Ck=yc()),Ck;a=C;if(0!==a)return a;a=window.event;a=void 0===a?16:jd(a.type);return a}function mh(a,b,c,d){if(50<zk)throw zk=0,Ak=null,Error(p$3(185));Ac(a,c,d);if(0===(K&2)||a!==R)a===R&&(0===(K&2)&&(rk|=c),4===T&&Dk(a,Z)),Ek(a,d),1===c&&0===K&&0===(b.mode&1)&&(Hj=B()+500,fg&&jg());}
    function Ek(a,b){var c=a.callbackNode;wc(a,b);var d=uc(a,a===R?Z:0);if(0===d)null!==c&&bc(c),a.callbackNode=null,a.callbackPriority=0;else if(b=d&-d,a.callbackPriority!==b){null!=c&&bc(c);if(1===b)0===a.tag?ig(Fk.bind(null,a)):hg(Fk.bind(null,a)),Jf(function(){0===(K&6)&&jg();}),c=null;else {switch(Dc(d)){case 1:c=fc;break;case 4:c=gc;break;case 16:c=hc;break;case 536870912:c=jc;break;default:c=hc;}c=Gk(c,Hk.bind(null,a));}a.callbackPriority=b;a.callbackNode=c;}}
    function Hk(a,b){Bk=-1;Ck=0;if(0!==(K&6))throw Error(p$3(327));var c=a.callbackNode;if(Ik()&&a.callbackNode!==c)return null;var d=uc(a,a===R?Z:0);if(0===d)return null;if(0!==(d&30)||0!==(d&a.expiredLanes)||b)b=Jk(a,d);else {b=d;var e=K;K|=2;var f=Kk();if(R!==a||Z!==b)vk=null,Hj=B()+500,Lk(a,b);do try{Mk();break}catch(h){Nk(a,h);}while(1);Qg();nk.current=f;K=e;null!==Y?b=0:(R=null,Z=0,b=T);}if(0!==b){2===b&&(e=xc(a),0!==e&&(d=e,b=Ok(a,e)));if(1===b)throw c=qk,Lk(a,0),Dk(a,d),Ek(a,B()),c;if(6===b)Dk(a,d);
    else {e=a.current.alternate;if(0===(d&30)&&!Pk(e)&&(b=Jk(a,d),2===b&&(f=xc(a),0!==f&&(d=f,b=Ok(a,f))),1===b))throw c=qk,Lk(a,0),Dk(a,d),Ek(a,B()),c;a.finishedWork=e;a.finishedLanes=d;switch(b){case 0:case 1:throw Error(p$3(345));case 2:Qk(a,uk,vk);break;case 3:Dk(a,d);if((d&130023424)===d&&(b=gk+500-B(),10<b)){if(0!==uc(a,0))break;e=a.suspendedLanes;if((e&d)!==d){L();a.pingedLanes|=a.suspendedLanes&e;break}a.timeoutHandle=Ff(Qk.bind(null,a,uk,vk),b);break}Qk(a,uk,vk);break;case 4:Dk(a,d);if((d&4194240)===
    d)break;b=a.eventTimes;for(e=-1;0<d;){var g=31-oc(d);f=1<<g;g=b[g];g>e&&(e=g);d&=~f;}d=e;d=B()-d;d=(120>d?120:480>d?480:1080>d?1080:1920>d?1920:3E3>d?3E3:4320>d?4320:1960*mk(d/1960))-d;if(10<d){a.timeoutHandle=Ff(Qk.bind(null,a,uk,vk),d);break}Qk(a,uk,vk);break;case 5:Qk(a,uk,vk);break;default:throw Error(p$3(329));}}}Ek(a,B());return a.callbackNode===c?Hk.bind(null,a):null}
    function Ok(a,b){var c=tk;a.current.memoizedState.isDehydrated&&(Lk(a,b).flags|=256);a=Jk(a,b);2!==a&&(b=uk,uk=c,null!==b&&Gj(b));return a}function Gj(a){null===uk?uk=a:uk.push.apply(uk,a);}
    function Pk(a){for(var b=a;;){if(b.flags&16384){var c=b.updateQueue;if(null!==c&&(c=c.stores,null!==c))for(var d=0;d<c.length;d++){var e=c[d],f=e.getSnapshot;e=e.value;try{if(!He(f(),e))return !1}catch(g){return !1}}}c=b.child;if(b.subtreeFlags&16384&&null!==c)c.return=b,b=c;else {if(b===a)break;for(;null===b.sibling;){if(null===b.return||b.return===a)return !0;b=b.return;}b.sibling.return=b.return;b=b.sibling;}}return !0}
    function Dk(a,b){b&=~sk;b&=~rk;a.suspendedLanes|=b;a.pingedLanes&=~b;for(a=a.expirationTimes;0<b;){var c=31-oc(b),d=1<<c;a[c]=-1;b&=~d;}}function Fk(a){if(0!==(K&6))throw Error(p$3(327));Ik();var b=uc(a,0);if(0===(b&1))return Ek(a,B()),null;var c=Jk(a,b);if(0!==a.tag&&2===c){var d=xc(a);0!==d&&(b=d,c=Ok(a,d));}if(1===c)throw c=qk,Lk(a,0),Dk(a,b),Ek(a,B()),c;if(6===c)throw Error(p$3(345));a.finishedWork=a.current.alternate;a.finishedLanes=b;Qk(a,uk,vk);Ek(a,B());return null}
    function Rk(a,b){var c=K;K|=1;try{return a(b)}finally{K=c,0===K&&(Hj=B()+500,fg&&jg());}}function Sk(a){null!==xk&&0===xk.tag&&0===(K&6)&&Ik();var b=K;K|=1;var c=pk.transition,d=C;try{if(pk.transition=null,C=1,a)return a()}finally{C=d,pk.transition=c,K=b,0===(K&6)&&jg();}}function Ij(){gj=fj.current;E(fj);}
    function Lk(a,b){a.finishedWork=null;a.finishedLanes=0;var c=a.timeoutHandle;-1!==c&&(a.timeoutHandle=-1,Gf(c));if(null!==Y)for(c=Y.return;null!==c;){var d=c;wg(d);switch(d.tag){case 1:d=d.type.childContextTypes;null!==d&&void 0!==d&&$f();break;case 3:Jh();E(Wf);E(H);Oh();break;case 5:Lh(d);break;case 4:Jh();break;case 13:E(M);break;case 19:E(M);break;case 10:Rg(d.type._context);break;case 22:case 23:Ij();}c=c.return;}R=a;Y=a=wh(a.current,null);Z=gj=b;T=0;qk=null;sk=rk=hh=0;uk=tk=null;if(null!==Wg){for(b=
    0;b<Wg.length;b++)if(c=Wg[b],d=c.interleaved,null!==d){c.interleaved=null;var e=d.next,f=c.pending;if(null!==f){var g=f.next;f.next=e;d.next=g;}c.pending=d;}Wg=null;}return a}
    function Nk(a,b){do{var c=Y;try{Qg();Ph.current=ai;if(Sh){for(var d=N.memoizedState;null!==d;){var e=d.queue;null!==e&&(e.pending=null);d=d.next;}Sh=!1;}Rh=0;P=O=N=null;Th=!1;Uh=0;ok.current=null;if(null===c||null===c.return){T=1;qk=b;Y=null;break}a:{var f=a,g=c.return,h=c,k=b;b=Z;h.flags|=32768;if(null!==k&&"object"===typeof k&&"function"===typeof k.then){var l=k,m=h,q=m.tag;if(0===(m.mode&1)&&(0===q||11===q||15===q)){var r=m.alternate;r?(m.updateQueue=r.updateQueue,m.memoizedState=r.memoizedState,
    m.lanes=r.lanes):(m.updateQueue=null,m.memoizedState=null);}var y=Vi(g);if(null!==y){y.flags&=-257;Wi(y,g,h,f,b);y.mode&1&&Ti(f,l,b);b=y;k=l;var n=b.updateQueue;if(null===n){var t=new Set;t.add(k);b.updateQueue=t;}else n.add(k);break a}else {if(0===(b&1)){Ti(f,l,b);uj();break a}k=Error(p$3(426));}}else if(I&&h.mode&1){var J=Vi(g);if(null!==J){0===(J.flags&65536)&&(J.flags|=256);Wi(J,g,h,f,b);Jg(Ki(k,h));break a}}f=k=Ki(k,h);4!==T&&(T=2);null===tk?tk=[f]:tk.push(f);f=g;do{switch(f.tag){case 3:f.flags|=65536;
    b&=-b;f.lanes|=b;var x=Oi(f,k,b);fh(f,x);break a;case 1:h=k;var w=f.type,u=f.stateNode;if(0===(f.flags&128)&&("function"===typeof w.getDerivedStateFromError||null!==u&&"function"===typeof u.componentDidCatch&&(null===Si||!Si.has(u)))){f.flags|=65536;b&=-b;f.lanes|=b;var F=Ri(f,h,b);fh(f,F);break a}}f=f.return;}while(null!==f)}Tk(c);}catch(na){b=na;Y===c&&null!==c&&(Y=c=c.return);continue}break}while(1)}function Kk(){var a=nk.current;nk.current=ai;return null===a?ai:a}
    function uj(){if(0===T||3===T||2===T)T=4;null===R||0===(hh&268435455)&&0===(rk&268435455)||Dk(R,Z);}function Jk(a,b){var c=K;K|=2;var d=Kk();if(R!==a||Z!==b)vk=null,Lk(a,b);do try{Uk();break}catch(e){Nk(a,e);}while(1);Qg();K=c;nk.current=d;if(null!==Y)throw Error(p$3(261));R=null;Z=0;return T}function Uk(){for(;null!==Y;)Vk(Y);}function Mk(){for(;null!==Y&&!cc();)Vk(Y);}function Vk(a){var b=Wk(a.alternate,a,gj);a.memoizedProps=a.pendingProps;null===b?Tk(a):Y=b;ok.current=null;}
    function Tk(a){var b=a;do{var c=b.alternate;a=b.return;if(0===(b.flags&32768)){if(c=Fj(c,b,gj),null!==c){Y=c;return}}else {c=Jj(c,b);if(null!==c){c.flags&=32767;Y=c;return}if(null!==a)a.flags|=32768,a.subtreeFlags=0,a.deletions=null;else {T=6;Y=null;return}}b=b.sibling;if(null!==b){Y=b;return}Y=b=a;}while(null!==b);0===T&&(T=5);}function Qk(a,b,c){var d=C,e=pk.transition;try{pk.transition=null,C=1,Xk(a,b,c,d);}finally{pk.transition=e,C=d;}return null}
    function Xk(a,b,c,d){do Ik();while(null!==xk);if(0!==(K&6))throw Error(p$3(327));c=a.finishedWork;var e=a.finishedLanes;if(null===c)return null;a.finishedWork=null;a.finishedLanes=0;if(c===a.current)throw Error(p$3(177));a.callbackNode=null;a.callbackPriority=0;var f=c.lanes|c.childLanes;Bc(a,f);a===R&&(Y=R=null,Z=0);0===(c.subtreeFlags&2064)&&0===(c.flags&2064)||wk||(wk=!0,Gk(hc,function(){Ik();return null}));f=0!==(c.flags&15990);if(0!==(c.subtreeFlags&15990)||f){f=pk.transition;pk.transition=null;
    var g=C;C=1;var h=K;K|=4;ok.current=null;Pj(a,c);ek(c,a);Oe(Df);dd=!!Cf;Df=Cf=null;a.current=c;ik(c);dc();K=h;C=g;pk.transition=f;}else a.current=c;wk&&(wk=!1,xk=a,yk=e);f=a.pendingLanes;0===f&&(Si=null);mc(c.stateNode);Ek(a,B());if(null!==b)for(d=a.onRecoverableError,c=0;c<b.length;c++)e=b[c],d(e.value,{componentStack:e.stack,digest:e.digest});if(Pi)throw Pi=!1,a=Qi,Qi=null,a;0!==(yk&1)&&0!==a.tag&&Ik();f=a.pendingLanes;0!==(f&1)?a===Ak?zk++:(zk=0,Ak=a):zk=0;jg();return null}
    function Ik(){if(null!==xk){var a=Dc(yk),b=pk.transition,c=C;try{pk.transition=null;C=16>a?16:a;if(null===xk)var d=!1;else {a=xk;xk=null;yk=0;if(0!==(K&6))throw Error(p$3(331));var e=K;K|=4;for(V=a.current;null!==V;){var f=V,g=f.child;if(0!==(V.flags&16)){var h=f.deletions;if(null!==h){for(var k=0;k<h.length;k++){var l=h[k];for(V=l;null!==V;){var m=V;switch(m.tag){case 0:case 11:case 15:Qj(8,m,f);}var q=m.child;if(null!==q)q.return=m,V=q;else for(;null!==V;){m=V;var r=m.sibling,y=m.return;Tj(m);if(m===
    l){V=null;break}if(null!==r){r.return=y;V=r;break}V=y;}}}var n=f.alternate;if(null!==n){var t=n.child;if(null!==t){n.child=null;do{var J=t.sibling;t.sibling=null;t=J;}while(null!==t)}}V=f;}}if(0!==(f.subtreeFlags&2064)&&null!==g)g.return=f,V=g;else b:for(;null!==V;){f=V;if(0!==(f.flags&2048))switch(f.tag){case 0:case 11:case 15:Qj(9,f,f.return);}var x=f.sibling;if(null!==x){x.return=f.return;V=x;break b}V=f.return;}}var w=a.current;for(V=w;null!==V;){g=V;var u=g.child;if(0!==(g.subtreeFlags&2064)&&null!==
    u)u.return=g,V=u;else b:for(g=w;null!==V;){h=V;if(0!==(h.flags&2048))try{switch(h.tag){case 0:case 11:case 15:Rj(9,h);}}catch(na){W(h,h.return,na);}if(h===g){V=null;break b}var F=h.sibling;if(null!==F){F.return=h.return;V=F;break b}V=h.return;}}K=e;jg();if(lc&&"function"===typeof lc.onPostCommitFiberRoot)try{lc.onPostCommitFiberRoot(kc,a);}catch(na){}d=!0;}return d}finally{C=c,pk.transition=b;}}return !1}function Yk(a,b,c){b=Ki(c,b);b=Oi(a,b,1);a=dh(a,b,1);b=L();null!==a&&(Ac(a,1,b),Ek(a,b));}
    function W(a,b,c){if(3===a.tag)Yk(a,a,c);else for(;null!==b;){if(3===b.tag){Yk(b,a,c);break}else if(1===b.tag){var d=b.stateNode;if("function"===typeof b.type.getDerivedStateFromError||"function"===typeof d.componentDidCatch&&(null===Si||!Si.has(d))){a=Ki(c,a);a=Ri(b,a,1);b=dh(b,a,1);a=L();null!==b&&(Ac(b,1,a),Ek(b,a));break}}b=b.return;}}
    function Ui(a,b,c){var d=a.pingCache;null!==d&&d.delete(b);b=L();a.pingedLanes|=a.suspendedLanes&c;R===a&&(Z&c)===c&&(4===T||3===T&&(Z&130023424)===Z&&500>B()-gk?Lk(a,0):sk|=c);Ek(a,b);}function Zk(a,b){0===b&&(0===(a.mode&1)?b=1:(b=sc,sc<<=1,0===(sc&130023424)&&(sc=4194304)));var c=L();a=Zg(a,b);null!==a&&(Ac(a,b,c),Ek(a,c));}function vj(a){var b=a.memoizedState,c=0;null!==b&&(c=b.retryLane);Zk(a,c);}
    function ck(a,b){var c=0;switch(a.tag){case 13:var d=a.stateNode;var e=a.memoizedState;null!==e&&(c=e.retryLane);break;case 19:d=a.stateNode;break;default:throw Error(p$3(314));}null!==d&&d.delete(b);Zk(a,c);}var Wk;
    Wk=function(a,b,c){if(null!==a)if(a.memoizedProps!==b.pendingProps||Wf.current)Ug=!0;else {if(0===(a.lanes&c)&&0===(b.flags&128))return Ug=!1,zj(a,b,c);Ug=0!==(a.flags&131072)?!0:!1;}else Ug=!1,I&&0!==(b.flags&1048576)&&ug(b,ng,b.index);b.lanes=0;switch(b.tag){case 2:var d=b.type;jj(a,b);a=b.pendingProps;var e=Yf(b,H.current);Tg(b,c);e=Xh(null,b,d,a,e,c);var f=bi();b.flags|=1;"object"===typeof e&&null!==e&&"function"===typeof e.render&&void 0===e.$$typeof?(b.tag=1,b.memoizedState=null,b.updateQueue=
    null,Zf(d)?(f=!0,cg(b)):f=!1,b.memoizedState=null!==e.state&&void 0!==e.state?e.state:null,ah(b),e.updater=nh,b.stateNode=e,e._reactInternals=b,rh(b,d,a,c),b=kj(null,b,d,!0,f,c)):(b.tag=0,I&&f&&vg(b),Yi(null,b,e,c),b=b.child);return b;case 16:d=b.elementType;a:{jj(a,b);a=b.pendingProps;e=d._init;d=e(d._payload);b.type=d;e=b.tag=$k(d);a=Lg(d,a);switch(e){case 0:b=dj(null,b,d,a,c);break a;case 1:b=ij(null,b,d,a,c);break a;case 11:b=Zi(null,b,d,a,c);break a;case 14:b=aj(null,b,d,Lg(d.type,a),c);break a}throw Error(p$3(306,
    d,""));}return b;case 0:return d=b.type,e=b.pendingProps,e=b.elementType===d?e:Lg(d,e),dj(a,b,d,e,c);case 1:return d=b.type,e=b.pendingProps,e=b.elementType===d?e:Lg(d,e),ij(a,b,d,e,c);case 3:a:{lj(b);if(null===a)throw Error(p$3(387));d=b.pendingProps;f=b.memoizedState;e=f.element;bh(a,b);gh(b,d,null,c);var g=b.memoizedState;d=g.element;if(f.isDehydrated)if(f={element:d,isDehydrated:!1,cache:g.cache,pendingSuspenseBoundaries:g.pendingSuspenseBoundaries,transitions:g.transitions},b.updateQueue.baseState=
    f,b.memoizedState=f,b.flags&256){e=Ki(Error(p$3(423)),b);b=mj(a,b,d,c,e);break a}else if(d!==e){e=Ki(Error(p$3(424)),b);b=mj(a,b,d,c,e);break a}else for(yg=Lf(b.stateNode.containerInfo.firstChild),xg=b,I=!0,zg=null,c=Ch(b,null,d,c),b.child=c;c;)c.flags=c.flags&-3|4096,c=c.sibling;else {Ig();if(d===e){b=$i(a,b,c);break a}Yi(a,b,d,c);}b=b.child;}return b;case 5:return Kh(b),null===a&&Eg(b),d=b.type,e=b.pendingProps,f=null!==a?a.memoizedProps:null,g=e.children,Ef(d,e)?g=null:null!==f&&Ef(d,f)&&(b.flags|=32),
    hj(a,b),Yi(a,b,g,c),b.child;case 6:return null===a&&Eg(b),null;case 13:return pj(a,b,c);case 4:return Ih(b,b.stateNode.containerInfo),d=b.pendingProps,null===a?b.child=Bh(b,null,d,c):Yi(a,b,d,c),b.child;case 11:return d=b.type,e=b.pendingProps,e=b.elementType===d?e:Lg(d,e),Zi(a,b,d,e,c);case 7:return Yi(a,b,b.pendingProps,c),b.child;case 8:return Yi(a,b,b.pendingProps.children,c),b.child;case 12:return Yi(a,b,b.pendingProps.children,c),b.child;case 10:a:{d=b.type._context;e=b.pendingProps;f=b.memoizedProps;
    g=e.value;G(Mg,d._currentValue);d._currentValue=g;if(null!==f)if(He(f.value,g)){if(f.children===e.children&&!Wf.current){b=$i(a,b,c);break a}}else for(f=b.child,null!==f&&(f.return=b);null!==f;){var h=f.dependencies;if(null!==h){g=f.child;for(var k=h.firstContext;null!==k;){if(k.context===d){if(1===f.tag){k=ch(-1,c&-c);k.tag=2;var l=f.updateQueue;if(null!==l){l=l.shared;var m=l.pending;null===m?k.next=k:(k.next=m.next,m.next=k);l.pending=k;}}f.lanes|=c;k=f.alternate;null!==k&&(k.lanes|=c);Sg(f.return,
    c,b);h.lanes|=c;break}k=k.next;}}else if(10===f.tag)g=f.type===b.type?null:f.child;else if(18===f.tag){g=f.return;if(null===g)throw Error(p$3(341));g.lanes|=c;h=g.alternate;null!==h&&(h.lanes|=c);Sg(g,c,b);g=f.sibling;}else g=f.child;if(null!==g)g.return=f;else for(g=f;null!==g;){if(g===b){g=null;break}f=g.sibling;if(null!==f){f.return=g.return;g=f;break}g=g.return;}f=g;}Yi(a,b,e.children,c);b=b.child;}return b;case 9:return e=b.type,d=b.pendingProps.children,Tg(b,c),e=Vg(e),d=d(e),b.flags|=1,Yi(a,b,d,c),
    b.child;case 14:return d=b.type,e=Lg(d,b.pendingProps),e=Lg(d.type,e),aj(a,b,d,e,c);case 15:return cj(a,b,b.type,b.pendingProps,c);case 17:return d=b.type,e=b.pendingProps,e=b.elementType===d?e:Lg(d,e),jj(a,b),b.tag=1,Zf(d)?(a=!0,cg(b)):a=!1,Tg(b,c),ph(b,d,e),rh(b,d,e,c),kj(null,b,d,!0,a,c);case 19:return yj(a,b,c);case 22:return ej(a,b,c)}throw Error(p$3(156,b.tag));};function Gk(a,b){return ac(a,b)}
    function al(a,b,c,d){this.tag=a;this.key=c;this.sibling=this.child=this.return=this.stateNode=this.type=this.elementType=null;this.index=0;this.ref=null;this.pendingProps=b;this.dependencies=this.memoizedState=this.updateQueue=this.memoizedProps=null;this.mode=d;this.subtreeFlags=this.flags=0;this.deletions=null;this.childLanes=this.lanes=0;this.alternate=null;}function Bg(a,b,c,d){return new al(a,b,c,d)}function bj(a){a=a.prototype;return !(!a||!a.isReactComponent)}
    function $k(a){if("function"===typeof a)return bj(a)?1:0;if(void 0!==a&&null!==a){a=a.$$typeof;if(a===Da)return 11;if(a===Ga)return 14}return 2}
    function wh(a,b){var c=a.alternate;null===c?(c=Bg(a.tag,b,a.key,a.mode),c.elementType=a.elementType,c.type=a.type,c.stateNode=a.stateNode,c.alternate=a,a.alternate=c):(c.pendingProps=b,c.type=a.type,c.flags=0,c.subtreeFlags=0,c.deletions=null);c.flags=a.flags&14680064;c.childLanes=a.childLanes;c.lanes=a.lanes;c.child=a.child;c.memoizedProps=a.memoizedProps;c.memoizedState=a.memoizedState;c.updateQueue=a.updateQueue;b=a.dependencies;c.dependencies=null===b?null:{lanes:b.lanes,firstContext:b.firstContext};
    c.sibling=a.sibling;c.index=a.index;c.ref=a.ref;return c}
    function yh(a,b,c,d,e,f){var g=2;d=a;if("function"===typeof a)bj(a)&&(g=1);else if("string"===typeof a)g=5;else a:switch(a){case ya:return Ah(c.children,e,f,b);case za:g=8;e|=8;break;case Aa:return a=Bg(12,c,b,e|2),a.elementType=Aa,a.lanes=f,a;case Ea:return a=Bg(13,c,b,e),a.elementType=Ea,a.lanes=f,a;case Fa:return a=Bg(19,c,b,e),a.elementType=Fa,a.lanes=f,a;case Ia:return qj(c,e,f,b);default:if("object"===typeof a&&null!==a)switch(a.$$typeof){case Ba:g=10;break a;case Ca:g=9;break a;case Da:g=11;
    break a;case Ga:g=14;break a;case Ha:g=16;d=null;break a}throw Error(p$3(130,null==a?a:typeof a,""));}b=Bg(g,c,b,e);b.elementType=a;b.type=d;b.lanes=f;return b}function Ah(a,b,c,d){a=Bg(7,a,d,b);a.lanes=c;return a}function qj(a,b,c,d){a=Bg(22,a,d,b);a.elementType=Ia;a.lanes=c;a.stateNode={isHidden:!1};return a}function xh(a,b,c){a=Bg(6,a,null,b);a.lanes=c;return a}
    function zh(a,b,c){b=Bg(4,null!==a.children?a.children:[],a.key,b);b.lanes=c;b.stateNode={containerInfo:a.containerInfo,pendingChildren:null,implementation:a.implementation};return b}
    function bl(a,b,c,d,e){this.tag=b;this.containerInfo=a;this.finishedWork=this.pingCache=this.current=this.pendingChildren=null;this.timeoutHandle=-1;this.callbackNode=this.pendingContext=this.context=null;this.callbackPriority=0;this.eventTimes=zc(0);this.expirationTimes=zc(-1);this.entangledLanes=this.finishedLanes=this.mutableReadLanes=this.expiredLanes=this.pingedLanes=this.suspendedLanes=this.pendingLanes=0;this.entanglements=zc(0);this.identifierPrefix=d;this.onRecoverableError=e;this.mutableSourceEagerHydrationData=
    null;}function cl(a,b,c,d,e,f,g,h,k){a=new bl(a,b,c,h,k);1===b?(b=1,!0===f&&(b|=8)):b=0;f=Bg(3,null,null,b);a.current=f;f.stateNode=a;f.memoizedState={element:d,isDehydrated:c,cache:null,transitions:null,pendingSuspenseBoundaries:null};ah(f);return a}function dl(a,b,c){var d=3<arguments.length&&void 0!==arguments[3]?arguments[3]:null;return {$$typeof:wa,key:null==d?null:""+d,children:a,containerInfo:b,implementation:c}}
    function el(a){if(!a)return Vf;a=a._reactInternals;a:{if(Vb(a)!==a||1!==a.tag)throw Error(p$3(170));var b=a;do{switch(b.tag){case 3:b=b.stateNode.context;break a;case 1:if(Zf(b.type)){b=b.stateNode.__reactInternalMemoizedMergedChildContext;break a}}b=b.return;}while(null!==b);throw Error(p$3(171));}if(1===a.tag){var c=a.type;if(Zf(c))return bg(a,c,b)}return b}
    function fl(a,b,c,d,e,f,g,h,k){a=cl(c,d,!0,a,e,f,g,h,k);a.context=el(null);c=a.current;d=L();e=lh(c);f=ch(d,e);f.callback=void 0!==b&&null!==b?b:null;dh(c,f,e);a.current.lanes=e;Ac(a,e,d);Ek(a,d);return a}function gl(a,b,c,d){var e=b.current,f=L(),g=lh(e);c=el(c);null===b.context?b.context=c:b.pendingContext=c;b=ch(f,g);b.payload={element:a};d=void 0===d?null:d;null!==d&&(b.callback=d);a=dh(e,b,g);null!==a&&(mh(a,e,g,f),eh(a,e,g));return g}
    function hl(a){a=a.current;if(!a.child)return null;switch(a.child.tag){case 5:return a.child.stateNode;default:return a.child.stateNode}}function il(a,b){a=a.memoizedState;if(null!==a&&null!==a.dehydrated){var c=a.retryLane;a.retryLane=0!==c&&c<b?c:b;}}function jl(a,b){il(a,b);(a=a.alternate)&&il(a,b);}function kl(){return null}var ll="function"===typeof reportError?reportError:function(a){console.error(a);};function ml(a){this._internalRoot=a;}
    nl.prototype.render=ml.prototype.render=function(a){var b=this._internalRoot;if(null===b)throw Error(p$3(409));gl(a,b,null,null);};nl.prototype.unmount=ml.prototype.unmount=function(){var a=this._internalRoot;if(null!==a){this._internalRoot=null;var b=a.containerInfo;Sk(function(){gl(null,a,null,null);});b[uf]=null;}};function nl(a){this._internalRoot=a;}
    nl.prototype.unstable_scheduleHydration=function(a){if(a){var b=Hc();a={blockedOn:null,target:a,priority:b};for(var c=0;c<Qc.length&&0!==b&&b<Qc[c].priority;c++);Qc.splice(c,0,a);0===c&&Vc(a);}};function ol(a){return !(!a||1!==a.nodeType&&9!==a.nodeType&&11!==a.nodeType)}function pl(a){return !(!a||1!==a.nodeType&&9!==a.nodeType&&11!==a.nodeType&&(8!==a.nodeType||" react-mount-point-unstable "!==a.nodeValue))}function ql(){}
    function rl(a,b,c,d,e){if(e){if("function"===typeof d){var f=d;d=function(){var a=hl(g);f.call(a);};}var g=fl(b,d,a,0,null,!1,!1,"",ql);a._reactRootContainer=g;a[uf]=g.current;sf(8===a.nodeType?a.parentNode:a);Sk();return g}for(;e=a.lastChild;)a.removeChild(e);if("function"===typeof d){var h=d;d=function(){var a=hl(k);h.call(a);};}var k=cl(a,0,!1,null,null,!1,!1,"",ql);a._reactRootContainer=k;a[uf]=k.current;sf(8===a.nodeType?a.parentNode:a);Sk(function(){gl(b,k,c,d);});return k}
    function sl(a,b,c,d,e){var f=c._reactRootContainer;if(f){var g=f;if("function"===typeof e){var h=e;e=function(){var a=hl(g);h.call(a);};}gl(b,g,a,e);}else g=rl(c,b,a,e,d);return hl(g)}Ec=function(a){switch(a.tag){case 3:var b=a.stateNode;if(b.current.memoizedState.isDehydrated){var c=tc(b.pendingLanes);0!==c&&(Cc(b,c|1),Ek(b,B()),0===(K&6)&&(Hj=B()+500,jg()));}break;case 13:Sk(function(){var b=Zg(a,1);if(null!==b){var c=L();mh(b,a,1,c);}}),jl(a,1);}};
    Fc=function(a){if(13===a.tag){var b=Zg(a,134217728);if(null!==b){var c=L();mh(b,a,134217728,c);}jl(a,134217728);}};Gc=function(a){if(13===a.tag){var b=lh(a),c=Zg(a,b);if(null!==c){var d=L();mh(c,a,b,d);}jl(a,b);}};Hc=function(){return C};Ic=function(a,b){var c=C;try{return C=a,b()}finally{C=c;}};
    yb=function(a,b,c){switch(b){case "input":bb(a,c);b=c.name;if("radio"===c.type&&null!=b){for(c=a;c.parentNode;)c=c.parentNode;c=c.querySelectorAll("input[name="+JSON.stringify(""+b)+'][type="radio"]');for(b=0;b<c.length;b++){var d=c[b];if(d!==a&&d.form===a.form){var e=Db(d);if(!e)throw Error(p$3(90));Wa(d);bb(d,e);}}}break;case "textarea":ib(a,c);break;case "select":b=c.value,null!=b&&fb(a,!!c.multiple,b,!1);}};Gb=Rk;Hb=Sk;
    var tl={usingClientEntryPoint:!1,Events:[Cb,ue,Db,Eb,Fb,Rk]},ul={findFiberByHostInstance:Wc,bundleType:0,version:"18.2.0",rendererPackageName:"react-dom"};
    var vl={bundleType:ul.bundleType,version:ul.version,rendererPackageName:ul.rendererPackageName,rendererConfig:ul.rendererConfig,overrideHookState:null,overrideHookStateDeletePath:null,overrideHookStateRenamePath:null,overrideProps:null,overridePropsDeletePath:null,overridePropsRenamePath:null,setErrorHandler:null,setSuspenseHandler:null,scheduleUpdate:null,currentDispatcherRef:ua.ReactCurrentDispatcher,findHostInstanceByFiber:function(a){a=Zb(a);return null===a?null:a.stateNode},findFiberByHostInstance:ul.findFiberByHostInstance||
    kl,findHostInstancesForRefresh:null,scheduleRefresh:null,scheduleRoot:null,setRefreshHandler:null,getCurrentFiber:null,reconcilerVersion:"18.2.0-next-9e3b772b8-20220608"};if("undefined"!==typeof __REACT_DEVTOOLS_GLOBAL_HOOK__){var wl=__REACT_DEVTOOLS_GLOBAL_HOOK__;if(!wl.isDisabled&&wl.supportsFiber)try{kc=wl.inject(vl),lc=wl;}catch(a){}}reactDom_production_min.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED=tl;
    reactDom_production_min.createPortal=function(a,b){var c=2<arguments.length&&void 0!==arguments[2]?arguments[2]:null;if(!ol(b))throw Error(p$3(200));return dl(a,b,null,c)};reactDom_production_min.createRoot=function(a,b){if(!ol(a))throw Error(p$3(299));var c=!1,d="",e=ll;null!==b&&void 0!==b&&(!0===b.unstable_strictMode&&(c=!0),void 0!==b.identifierPrefix&&(d=b.identifierPrefix),void 0!==b.onRecoverableError&&(e=b.onRecoverableError));b=cl(a,1,!1,null,null,c,!1,d,e);a[uf]=b.current;sf(8===a.nodeType?a.parentNode:a);return new ml(b)};
    reactDom_production_min.findDOMNode=function(a){if(null==a)return null;if(1===a.nodeType)return a;var b=a._reactInternals;if(void 0===b){if("function"===typeof a.render)throw Error(p$3(188));a=Object.keys(a).join(",");throw Error(p$3(268,a));}a=Zb(b);a=null===a?null:a.stateNode;return a};reactDom_production_min.flushSync=function(a){return Sk(a)};reactDom_production_min.hydrate=function(a,b,c){if(!pl(b))throw Error(p$3(200));return sl(null,a,b,!0,c)};
    reactDom_production_min.hydrateRoot=function(a,b,c){if(!ol(a))throw Error(p$3(405));var d=null!=c&&c.hydratedSources||null,e=!1,f="",g=ll;null!==c&&void 0!==c&&(!0===c.unstable_strictMode&&(e=!0),void 0!==c.identifierPrefix&&(f=c.identifierPrefix),void 0!==c.onRecoverableError&&(g=c.onRecoverableError));b=fl(b,null,a,1,null!=c?c:null,e,!1,f,g);a[uf]=b.current;sf(a);if(d)for(a=0;a<d.length;a++)c=d[a],e=c._getVersion,e=e(c._source),null==b.mutableSourceEagerHydrationData?b.mutableSourceEagerHydrationData=[c,e]:b.mutableSourceEagerHydrationData.push(c,
    e);return new nl(b)};reactDom_production_min.render=function(a,b,c){if(!pl(b))throw Error(p$3(200));return sl(null,a,b,!1,c)};reactDom_production_min.unmountComponentAtNode=function(a){if(!pl(a))throw Error(p$3(40));return a._reactRootContainer?(Sk(function(){sl(null,null,a,!1,function(){a._reactRootContainer=null;a[uf]=null;});}),!0):!1};reactDom_production_min.unstable_batchedUpdates=Rk;
    reactDom_production_min.unstable_renderSubtreeIntoContainer=function(a,b,c,d){if(!pl(c))throw Error(p$3(200));if(null==a||void 0===a._reactInternals)throw Error(p$3(38));return sl(a,b,c,!1,d)};reactDom_production_min.version="18.2.0-next-9e3b772b8-20220608";

    function checkDCE() {
      /* global __REACT_DEVTOOLS_GLOBAL_HOOK__ */
      if (
        typeof __REACT_DEVTOOLS_GLOBAL_HOOK__ === 'undefined' ||
        typeof __REACT_DEVTOOLS_GLOBAL_HOOK__.checkDCE !== 'function'
      ) {
        return;
      }
      try {
        // Verify that the code above has been dead code eliminated (DCE'd).
        __REACT_DEVTOOLS_GLOBAL_HOOK__.checkDCE(checkDCE);
      } catch (err) {
        // DevTools shouldn't crash React, no matter what.
        // We should still report in case we break this code.
        console.error(err);
      }
    }

    {
      // DCE check should happen before ReactDOM bundle executes so that
      // DevTools can report bad minification during injection.
      checkDCE();
      reactDom.exports = reactDom_production_min;
    }

    var reactDomExports = reactDom.exports;

    var createRoot;

    var m$2 = reactDomExports;
    {
      createRoot = m$2.createRoot;
      m$2.hydrateRoot;
    }

    const common = {
      black: '#000',
      white: '#fff'
    };

    const red = {
      50: '#ffebee',
      100: '#ffcdd2',
      200: '#ef9a9a',
      300: '#e57373',
      400: '#ef5350',
      500: '#f44336',
      600: '#e53935',
      700: '#d32f2f',
      800: '#c62828',
      900: '#b71c1c',
      A100: '#ff8a80',
      A200: '#ff5252',
      A400: '#ff1744',
      A700: '#d50000'
    };

    const purple = {
      50: '#f3e5f5',
      100: '#e1bee7',
      200: '#ce93d8',
      300: '#ba68c8',
      400: '#ab47bc',
      500: '#9c27b0',
      600: '#8e24aa',
      700: '#7b1fa2',
      800: '#6a1b9a',
      900: '#4a148c',
      A100: '#ea80fc',
      A200: '#e040fb',
      A400: '#d500f9',
      A700: '#aa00ff'
    };

    const blue = {
      50: '#e3f2fd',
      100: '#bbdefb',
      200: '#90caf9',
      300: '#64b5f6',
      400: '#42a5f5',
      500: '#2196f3',
      600: '#1e88e5',
      700: '#1976d2',
      800: '#1565c0',
      900: '#0d47a1',
      A100: '#82b1ff',
      A200: '#448aff',
      A400: '#2979ff',
      A700: '#2962ff'
    };

    const lightBlue = {
      50: '#e1f5fe',
      100: '#b3e5fc',
      200: '#81d4fa',
      300: '#4fc3f7',
      400: '#29b6f6',
      500: '#03a9f4',
      600: '#039be5',
      700: '#0288d1',
      800: '#0277bd',
      900: '#01579b',
      A100: '#80d8ff',
      A200: '#40c4ff',
      A400: '#00b0ff',
      A700: '#0091ea'
    };

    const green = {
      50: '#e8f5e9',
      100: '#c8e6c9',
      200: '#a5d6a7',
      300: '#81c784',
      400: '#66bb6a',
      500: '#4caf50',
      600: '#43a047',
      700: '#388e3c',
      800: '#2e7d32',
      900: '#1b5e20',
      A100: '#b9f6ca',
      A200: '#69f0ae',
      A400: '#00e676',
      A700: '#00c853'
    };

    const orange = {
      50: '#fff3e0',
      100: '#ffe0b2',
      200: '#ffcc80',
      300: '#ffb74d',
      400: '#ffa726',
      500: '#ff9800',
      600: '#fb8c00',
      700: '#f57c00',
      800: '#ef6c00',
      900: '#e65100',
      A100: '#ffd180',
      A200: '#ffab40',
      A400: '#ff9100',
      A700: '#ff6d00'
    };

    const grey = {
      50: '#fafafa',
      100: '#f5f5f5',
      200: '#eeeeee',
      300: '#e0e0e0',
      400: '#bdbdbd',
      500: '#9e9e9e',
      600: '#757575',
      700: '#616161',
      800: '#424242',
      900: '#212121',
      A100: '#f5f5f5',
      A200: '#eeeeee',
      A400: '#bdbdbd',
      A700: '#616161'
    };

    function _extends$5() {
      _extends$5 = Object.assign ? Object.assign.bind() : function (target) {
        for (var i = 1; i < arguments.length; i++) {
          var source = arguments[i];
          for (var key in source) {
            if (Object.prototype.hasOwnProperty.call(source, key)) {
              target[key] = source[key];
            }
          }
        }
        return target;
      };
      return _extends$5.apply(this, arguments);
    }

    function isPlainObject$1(item) {
      return item !== null && typeof item === 'object' && item.constructor === Object;
    }
    function deepClone(source) {
      if (!isPlainObject$1(source)) {
        return source;
      }
      const output = {};
      Object.keys(source).forEach(key => {
        output[key] = deepClone(source[key]);
      });
      return output;
    }
    function deepmerge(target, source, options = {
      clone: true
    }) {
      const output = options.clone ? _extends$5({}, target) : target;
      if (isPlainObject$1(target) && isPlainObject$1(source)) {
        Object.keys(source).forEach(key => {
          // Avoid prototype pollution
          if (key === '__proto__') {
            return;
          }
          if (isPlainObject$1(source[key]) && key in target && isPlainObject$1(target[key])) {
            // Since `output` is a clone of `target` and we have narrowed `target` in this block we can cast to the same type.
            output[key] = deepmerge(target[key], source[key], options);
          } else if (options.clone) {
            output[key] = isPlainObject$1(source[key]) ? deepClone(source[key]) : source[key];
          } else {
            output[key] = source[key];
          }
        });
      }
      return output;
    }

    /**
     * WARNING: Don't import this directly.
     * Use `MuiError` from `@mui/utils/macros/MuiError.macro` instead.
     * @param {number} code
     */
    function formatMuiErrorMessage(code) {
      // Apply babel-plugin-transform-template-literals in loose mode
      // loose mode is safe iff we're concatenating primitives
      // see https://babeljs.io/docs/en/babel-plugin-transform-template-literals#loose
      /* eslint-disable prefer-template */
      let url = 'https://mui.com/production-error/?code=' + code;
      for (let i = 1; i < arguments.length; i += 1) {
        // rest params over-transpile for this case
        // eslint-disable-next-line prefer-rest-params
        url += '&args[]=' + encodeURIComponent(arguments[i]);
      }
      return 'Minified MUI error #' + code + '; visit ' + url + ' for the full message.';
      /* eslint-enable prefer-template */
    }

    // It should to be noted that this function isn't equivalent to `text-transform: capitalize`.
    //
    // A strict capitalization should uppercase the first letter of each word in the sentence.
    // We only handle the first word.
    function capitalize(string) {
      if (typeof string !== 'string') {
        throw new Error(formatMuiErrorMessage(7));
      }
      return string.charAt(0).toUpperCase() + string.slice(1);
    }

    // Corresponds to 10 frames at 60 Hz.
    // A few bytes payload overhead when lodash/debounce is ~3 kB and debounce ~300 B.
    function debounce(func, wait = 166) {
      let timeout;
      function debounced(...args) {
        const later = () => {
          // @ts-ignore
          func.apply(this, args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
      }
      debounced.clear = () => {
        clearTimeout(timeout);
      };
      return debounced;
    }

    function ownerDocument(node) {
      return node && node.ownerDocument || document;
    }

    function ownerWindow(node) {
      const doc = ownerDocument(node);
      return doc.defaultView || window;
    }

    /**
     * TODO v5: consider making it private
     *
     * passes {value} to {ref}
     *
     * WARNING: Be sure to only call this inside a callback that is passed as a ref.
     * Otherwise, make sure to cleanup the previous {ref} if it changes. See
     * https://github.com/mui/material-ui/issues/13539
     *
     * Useful if you want to expose the ref of an inner component to the public API
     * while still using it inside the component.
     * @param ref A ref callback or ref object. If anything falsy, this is a no-op.
     */
    function setRef(ref, value) {
      if (typeof ref === 'function') {
        ref(value);
      } else if (ref) {
        ref.current = value;
      }
    }

    const useEnhancedEffect = reactExports.useLayoutEffect ;
    var useEnhancedEffect$1 = useEnhancedEffect;

    function useForkRef(...refs) {
      /**
       * This will create a new function if the refs passed to this hook change and are all defined.
       * This means react will call the old forkRef with `null` and the new forkRef
       * with the ref. Cleanup naturally emerges from this behavior.
       */
      return reactExports.useMemo(() => {
        if (refs.every(ref => ref == null)) {
          return null;
        }
        return instance => {
          refs.forEach(ref => {
            setRef(ref, instance);
          });
        };
        // eslint-disable-next-line react-hooks/exhaustive-deps
      }, refs);
    }

    /**
     * Add keys, values of `defaultProps` that does not exist in `props`
     * @param {object} defaultProps
     * @param {object} props
     * @returns {object} resolved props
     */
    function resolveProps(defaultProps, props) {
      const output = _extends$5({}, props);
      Object.keys(defaultProps).forEach(propName => {
        if (propName.toString().match(/^(components|slots)$/)) {
          output[propName] = _extends$5({}, defaultProps[propName], output[propName]);
        } else if (propName.toString().match(/^(componentsProps|slotProps)$/)) {
          const defaultSlotProps = defaultProps[propName] || {};
          const slotProps = props[propName];
          output[propName] = {};
          if (!slotProps || !Object.keys(slotProps)) {
            // Reduce the iteration if the slot props is empty
            output[propName] = defaultSlotProps;
          } else if (!defaultSlotProps || !Object.keys(defaultSlotProps)) {
            // Reduce the iteration if the default slot props is empty
            output[propName] = slotProps;
          } else {
            output[propName] = _extends$5({}, slotProps);
            Object.keys(defaultSlotProps).forEach(slotPropName => {
              output[propName][slotPropName] = resolveProps(defaultSlotProps[slotPropName], slotProps[slotPropName]);
            });
          }
        } else if (output[propName] === undefined) {
          output[propName] = defaultProps[propName];
        }
      });
      return output;
    }

    function composeClasses(slots, getUtilityClass, classes = undefined) {
      const output = {};
      Object.keys(slots).forEach(
      // `Objet.keys(slots)` can't be wider than `T` because we infer `T` from `slots`.
      // @ts-expect-error https://github.com/microsoft/TypeScript/pull/12253#issuecomment-263132208
      slot => {
        output[slot] = slots[slot].reduce((acc, key) => {
          if (key) {
            const utilityClass = getUtilityClass(key);
            if (utilityClass !== '') {
              acc.push(utilityClass);
            }
            if (classes && classes[key]) {
              acc.push(classes[key]);
            }
          }
          return acc;
        }, []).join(' ');
      });
      return output;
    }

    const defaultGenerator = componentName => componentName;
    const createClassNameGenerator = () => {
      let generate = defaultGenerator;
      return {
        configure(generator) {
          generate = generator;
        },
        generate(componentName) {
          return generate(componentName);
        },
        reset() {
          generate = defaultGenerator;
        }
      };
    };
    const ClassNameGenerator = createClassNameGenerator();
    var ClassNameGenerator$1 = ClassNameGenerator;

    const globalStateClassesMapping = {
      active: 'active',
      checked: 'checked',
      completed: 'completed',
      disabled: 'disabled',
      readOnly: 'readOnly',
      error: 'error',
      expanded: 'expanded',
      focused: 'focused',
      focusVisible: 'focusVisible',
      required: 'required',
      selected: 'selected'
    };
    function generateUtilityClass(componentName, slot, globalStatePrefix = 'Mui') {
      const globalStateClass = globalStateClassesMapping[slot];
      return globalStateClass ? `${globalStatePrefix}-${globalStateClass}` : `${ClassNameGenerator$1.generate(componentName)}-${slot}`;
    }

    function generateUtilityClasses(componentName, slots, globalStatePrefix = 'Mui') {
      const result = {};
      slots.forEach(slot => {
        result[slot] = generateUtilityClass(componentName, slot, globalStatePrefix);
      });
      return result;
    }

    var THEME_ID = '$$material';

    function _extends$4() {
      _extends$4 = Object.assign ? Object.assign.bind() : function (target) {
        for (var i = 1; i < arguments.length; i++) {
          var source = arguments[i];
          for (var key in source) {
            if (Object.prototype.hasOwnProperty.call(source, key)) {
              target[key] = source[key];
            }
          }
        }
        return target;
      };
      return _extends$4.apply(this, arguments);
    }

    function _objectWithoutPropertiesLoose$2(source, excluded) {
      if (source == null) return {};
      var target = {};
      var sourceKeys = Object.keys(source);
      var key, i;
      for (i = 0; i < sourceKeys.length; i++) {
        key = sourceKeys[i];
        if (excluded.indexOf(key) >= 0) continue;
        target[key] = source[key];
      }
      return target;
    }

    function _extends$3() {
      _extends$3 = Object.assign ? Object.assign.bind() : function (target) {
        for (var i = 1; i < arguments.length; i++) {
          var source = arguments[i];
          for (var key in source) {
            if (Object.prototype.hasOwnProperty.call(source, key)) {
              target[key] = source[key];
            }
          }
        }
        return target;
      };
      return _extends$3.apply(this, arguments);
    }

    function memoize$1(fn) {
      var cache = Object.create(null);
      return function (arg) {
        if (cache[arg] === undefined) cache[arg] = fn(arg);
        return cache[arg];
      };
    }

    var reactPropsRegex = /^((children|dangerouslySetInnerHTML|key|ref|autoFocus|defaultValue|defaultChecked|innerHTML|suppressContentEditableWarning|suppressHydrationWarning|valueLink|abbr|accept|acceptCharset|accessKey|action|allow|allowUserMedia|allowPaymentRequest|allowFullScreen|allowTransparency|alt|async|autoComplete|autoPlay|capture|cellPadding|cellSpacing|challenge|charSet|checked|cite|classID|className|cols|colSpan|content|contentEditable|contextMenu|controls|controlsList|coords|crossOrigin|data|dateTime|decoding|default|defer|dir|disabled|disablePictureInPicture|download|draggable|encType|enterKeyHint|form|formAction|formEncType|formMethod|formNoValidate|formTarget|frameBorder|headers|height|hidden|high|href|hrefLang|htmlFor|httpEquiv|id|inputMode|integrity|is|keyParams|keyType|kind|label|lang|list|loading|loop|low|marginHeight|marginWidth|max|maxLength|media|mediaGroup|method|min|minLength|multiple|muted|name|nonce|noValidate|open|optimum|pattern|placeholder|playsInline|poster|preload|profile|radioGroup|readOnly|referrerPolicy|rel|required|reversed|role|rows|rowSpan|sandbox|scope|scoped|scrolling|seamless|selected|shape|size|sizes|slot|span|spellCheck|src|srcDoc|srcLang|srcSet|start|step|style|summary|tabIndex|target|title|translate|type|useMap|value|width|wmode|wrap|about|datatype|inlist|prefix|property|resource|typeof|vocab|autoCapitalize|autoCorrect|autoSave|color|incremental|fallback|inert|itemProp|itemScope|itemType|itemID|itemRef|on|option|results|security|unselectable|accentHeight|accumulate|additive|alignmentBaseline|allowReorder|alphabetic|amplitude|arabicForm|ascent|attributeName|attributeType|autoReverse|azimuth|baseFrequency|baselineShift|baseProfile|bbox|begin|bias|by|calcMode|capHeight|clip|clipPathUnits|clipPath|clipRule|colorInterpolation|colorInterpolationFilters|colorProfile|colorRendering|contentScriptType|contentStyleType|cursor|cx|cy|d|decelerate|descent|diffuseConstant|direction|display|divisor|dominantBaseline|dur|dx|dy|edgeMode|elevation|enableBackground|end|exponent|externalResourcesRequired|fill|fillOpacity|fillRule|filter|filterRes|filterUnits|floodColor|floodOpacity|focusable|fontFamily|fontSize|fontSizeAdjust|fontStretch|fontStyle|fontVariant|fontWeight|format|from|fr|fx|fy|g1|g2|glyphName|glyphOrientationHorizontal|glyphOrientationVertical|glyphRef|gradientTransform|gradientUnits|hanging|horizAdvX|horizOriginX|ideographic|imageRendering|in|in2|intercept|k|k1|k2|k3|k4|kernelMatrix|kernelUnitLength|kerning|keyPoints|keySplines|keyTimes|lengthAdjust|letterSpacing|lightingColor|limitingConeAngle|local|markerEnd|markerMid|markerStart|markerHeight|markerUnits|markerWidth|mask|maskContentUnits|maskUnits|mathematical|mode|numOctaves|offset|opacity|operator|order|orient|orientation|origin|overflow|overlinePosition|overlineThickness|panose1|paintOrder|pathLength|patternContentUnits|patternTransform|patternUnits|pointerEvents|points|pointsAtX|pointsAtY|pointsAtZ|preserveAlpha|preserveAspectRatio|primitiveUnits|r|radius|refX|refY|renderingIntent|repeatCount|repeatDur|requiredExtensions|requiredFeatures|restart|result|rotate|rx|ry|scale|seed|shapeRendering|slope|spacing|specularConstant|specularExponent|speed|spreadMethod|startOffset|stdDeviation|stemh|stemv|stitchTiles|stopColor|stopOpacity|strikethroughPosition|strikethroughThickness|string|stroke|strokeDasharray|strokeDashoffset|strokeLinecap|strokeLinejoin|strokeMiterlimit|strokeOpacity|strokeWidth|surfaceScale|systemLanguage|tableValues|targetX|targetY|textAnchor|textDecoration|textRendering|textLength|to|transform|u1|u2|underlinePosition|underlineThickness|unicode|unicodeBidi|unicodeRange|unitsPerEm|vAlphabetic|vHanging|vIdeographic|vMathematical|values|vectorEffect|version|vertAdvY|vertOriginX|vertOriginY|viewBox|viewTarget|visibility|widths|wordSpacing|writingMode|x|xHeight|x1|x2|xChannelSelector|xlinkActuate|xlinkArcrole|xlinkHref|xlinkRole|xlinkShow|xlinkTitle|xlinkType|xmlBase|xmlns|xmlnsXlink|xmlLang|xmlSpace|y|y1|y2|yChannelSelector|z|zoomAndPan|for|class|autofocus)|(([Dd][Aa][Tt][Aa]|[Aa][Rr][Ii][Aa]|x)-.*))$/; // https://esbench.com/bench/5bfee68a4cd7e6009ef61d23

    var isPropValid = /* #__PURE__ */memoize$1(function (prop) {
      return reactPropsRegex.test(prop) || prop.charCodeAt(0) === 111
      /* o */
      && prop.charCodeAt(1) === 110
      /* n */
      && prop.charCodeAt(2) < 91;
    }
    /* Z+1 */
    );

    /*

    Based off glamor's StyleSheet, thanks Sunil ❤️

    high performance StyleSheet for css-in-js systems

    - uses multiple style tags behind the scenes for millions of rules
    - uses `insertRule` for appending in production for *much* faster performance

    // usage

    import { StyleSheet } from '@emotion/sheet'

    let styleSheet = new StyleSheet({ key: '', container: document.head })

    styleSheet.insert('#box { border: 1px solid red; }')
    - appends a css rule into the stylesheet

    styleSheet.flush()
    - empties the stylesheet of all its contents

    */
    // $FlowFixMe
    function sheetForTag(tag) {
      if (tag.sheet) {
        // $FlowFixMe
        return tag.sheet;
      } // this weirdness brought to you by firefox

      /* istanbul ignore next */


      for (var i = 0; i < document.styleSheets.length; i++) {
        if (document.styleSheets[i].ownerNode === tag) {
          // $FlowFixMe
          return document.styleSheets[i];
        }
      }
    }

    function createStyleElement(options) {
      var tag = document.createElement('style');
      tag.setAttribute('data-emotion', options.key);

      if (options.nonce !== undefined) {
        tag.setAttribute('nonce', options.nonce);
      }

      tag.appendChild(document.createTextNode(''));
      tag.setAttribute('data-s', '');
      return tag;
    }

    var StyleSheet = /*#__PURE__*/function () {
      // Using Node instead of HTMLElement since container may be a ShadowRoot
      function StyleSheet(options) {
        var _this = this;

        this._insertTag = function (tag) {
          var before;

          if (_this.tags.length === 0) {
            if (_this.insertionPoint) {
              before = _this.insertionPoint.nextSibling;
            } else if (_this.prepend) {
              before = _this.container.firstChild;
            } else {
              before = _this.before;
            }
          } else {
            before = _this.tags[_this.tags.length - 1].nextSibling;
          }

          _this.container.insertBefore(tag, before);

          _this.tags.push(tag);
        };

        this.isSpeedy = options.speedy === undefined ? "production" === 'production' : options.speedy;
        this.tags = [];
        this.ctr = 0;
        this.nonce = options.nonce; // key is the value of the data-emotion attribute, it's used to identify different sheets

        this.key = options.key;
        this.container = options.container;
        this.prepend = options.prepend;
        this.insertionPoint = options.insertionPoint;
        this.before = null;
      }

      var _proto = StyleSheet.prototype;

      _proto.hydrate = function hydrate(nodes) {
        nodes.forEach(this._insertTag);
      };

      _proto.insert = function insert(rule) {
        // the max length is how many rules we have per style tag, it's 65000 in speedy mode
        // it's 1 in dev because we insert source maps that map a single rule to a location
        // and you can only have one source map per style tag
        if (this.ctr % (this.isSpeedy ? 65000 : 1) === 0) {
          this._insertTag(createStyleElement(this));
        }

        var tag = this.tags[this.tags.length - 1];

        if (this.isSpeedy) {
          var sheet = sheetForTag(tag);

          try {
            // this is the ultrafast version, works across browsers
            // the big drawback is that the css won't be editable in devtools
            sheet.insertRule(rule, sheet.cssRules.length);
          } catch (e) {
          }
        } else {
          tag.appendChild(document.createTextNode(rule));
        }

        this.ctr++;
      };

      _proto.flush = function flush() {
        // $FlowFixMe
        this.tags.forEach(function (tag) {
          return tag.parentNode && tag.parentNode.removeChild(tag);
        });
        this.tags = [];
        this.ctr = 0;
      };

      return StyleSheet;
    }();

    var MS = '-ms-';
    var MOZ = '-moz-';
    var WEBKIT = '-webkit-';

    var COMMENT = 'comm';
    var RULESET = 'rule';
    var DECLARATION = 'decl';
    var IMPORT = '@import';
    var KEYFRAMES = '@keyframes';
    var LAYER = '@layer';

    /**
     * @param {number}
     * @return {number}
     */
    var abs = Math.abs;

    /**
     * @param {number}
     * @return {string}
     */
    var from = String.fromCharCode;

    /**
     * @param {object}
     * @return {object}
     */
    var assign = Object.assign;

    /**
     * @param {string} value
     * @param {number} length
     * @return {number}
     */
    function hash (value, length) {
    	return charat(value, 0) ^ 45 ? (((((((length << 2) ^ charat(value, 0)) << 2) ^ charat(value, 1)) << 2) ^ charat(value, 2)) << 2) ^ charat(value, 3) : 0
    }

    /**
     * @param {string} value
     * @return {string}
     */
    function trim (value) {
    	return value.trim()
    }

    /**
     * @param {string} value
     * @param {RegExp} pattern
     * @return {string?}
     */
    function match (value, pattern) {
    	return (value = pattern.exec(value)) ? value[0] : value
    }

    /**
     * @param {string} value
     * @param {(string|RegExp)} pattern
     * @param {string} replacement
     * @return {string}
     */
    function replace (value, pattern, replacement) {
    	return value.replace(pattern, replacement)
    }

    /**
     * @param {string} value
     * @param {string} search
     * @return {number}
     */
    function indexof (value, search) {
    	return value.indexOf(search)
    }

    /**
     * @param {string} value
     * @param {number} index
     * @return {number}
     */
    function charat (value, index) {
    	return value.charCodeAt(index) | 0
    }

    /**
     * @param {string} value
     * @param {number} begin
     * @param {number} end
     * @return {string}
     */
    function substr (value, begin, end) {
    	return value.slice(begin, end)
    }

    /**
     * @param {string} value
     * @return {number}
     */
    function strlen (value) {
    	return value.length
    }

    /**
     * @param {any[]} value
     * @return {number}
     */
    function sizeof (value) {
    	return value.length
    }

    /**
     * @param {any} value
     * @param {any[]} array
     * @return {any}
     */
    function append (value, array) {
    	return array.push(value), value
    }

    /**
     * @param {string[]} array
     * @param {function} callback
     * @return {string}
     */
    function combine (array, callback) {
    	return array.map(callback).join('')
    }

    var line = 1;
    var column = 1;
    var length = 0;
    var position = 0;
    var character = 0;
    var characters = '';

    /**
     * @param {string} value
     * @param {object | null} root
     * @param {object | null} parent
     * @param {string} type
     * @param {string[] | string} props
     * @param {object[] | string} children
     * @param {number} length
     */
    function node (value, root, parent, type, props, children, length) {
    	return {value: value, root: root, parent: parent, type: type, props: props, children: children, line: line, column: column, length: length, return: ''}
    }

    /**
     * @param {object} root
     * @param {object} props
     * @return {object}
     */
    function copy$1 (root, props) {
    	return assign(node('', null, null, '', null, null, 0), root, {length: -root.length}, props)
    }

    /**
     * @return {number}
     */
    function char () {
    	return character
    }

    /**
     * @return {number}
     */
    function prev () {
    	character = position > 0 ? charat(characters, --position) : 0;

    	if (column--, character === 10)
    		column = 1, line--;

    	return character
    }

    /**
     * @return {number}
     */
    function next () {
    	character = position < length ? charat(characters, position++) : 0;

    	if (column++, character === 10)
    		column = 1, line++;

    	return character
    }

    /**
     * @return {number}
     */
    function peek () {
    	return charat(characters, position)
    }

    /**
     * @return {number}
     */
    function caret () {
    	return position
    }

    /**
     * @param {number} begin
     * @param {number} end
     * @return {string}
     */
    function slice (begin, end) {
    	return substr(characters, begin, end)
    }

    /**
     * @param {number} type
     * @return {number}
     */
    function token (type) {
    	switch (type) {
    		// \0 \t \n \r \s whitespace token
    		case 0: case 9: case 10: case 13: case 32:
    			return 5
    		// ! + , / > @ ~ isolate token
    		case 33: case 43: case 44: case 47: case 62: case 64: case 126:
    		// ; { } breakpoint token
    		case 59: case 123: case 125:
    			return 4
    		// : accompanied token
    		case 58:
    			return 3
    		// " ' ( [ opening delimit token
    		case 34: case 39: case 40: case 91:
    			return 2
    		// ) ] closing delimit token
    		case 41: case 93:
    			return 1
    	}

    	return 0
    }

    /**
     * @param {string} value
     * @return {any[]}
     */
    function alloc (value) {
    	return line = column = 1, length = strlen(characters = value), position = 0, []
    }

    /**
     * @param {any} value
     * @return {any}
     */
    function dealloc (value) {
    	return characters = '', value
    }

    /**
     * @param {number} type
     * @return {string}
     */
    function delimit (type) {
    	return trim(slice(position - 1, delimiter(type === 91 ? type + 2 : type === 40 ? type + 1 : type)))
    }

    /**
     * @param {number} type
     * @return {string}
     */
    function whitespace (type) {
    	while (character = peek())
    		if (character < 33)
    			next();
    		else
    			break

    	return token(type) > 2 || token(character) > 3 ? '' : ' '
    }

    /**
     * @param {number} index
     * @param {number} count
     * @return {string}
     */
    function escaping (index, count) {
    	while (--count && next())
    		// not 0-9 A-F a-f
    		if (character < 48 || character > 102 || (character > 57 && character < 65) || (character > 70 && character < 97))
    			break

    	return slice(index, caret() + (count < 6 && peek() == 32 && next() == 32))
    }

    /**
     * @param {number} type
     * @return {number}
     */
    function delimiter (type) {
    	while (next())
    		switch (character) {
    			// ] ) " '
    			case type:
    				return position
    			// " '
    			case 34: case 39:
    				if (type !== 34 && type !== 39)
    					delimiter(character);
    				break
    			// (
    			case 40:
    				if (type === 41)
    					delimiter(type);
    				break
    			// \
    			case 92:
    				next();
    				break
    		}

    	return position
    }

    /**
     * @param {number} type
     * @param {number} index
     * @return {number}
     */
    function commenter (type, index) {
    	while (next())
    		// //
    		if (type + character === 47 + 10)
    			break
    		// /*
    		else if (type + character === 42 + 42 && peek() === 47)
    			break

    	return '/*' + slice(index, position - 1) + '*' + from(type === 47 ? type : next())
    }

    /**
     * @param {number} index
     * @return {string}
     */
    function identifier (index) {
    	while (!token(peek()))
    		next();

    	return slice(index, position)
    }

    /**
     * @param {string} value
     * @return {object[]}
     */
    function compile (value) {
    	return dealloc(parse('', null, null, null, [''], value = alloc(value), 0, [0], value))
    }

    /**
     * @param {string} value
     * @param {object} root
     * @param {object?} parent
     * @param {string[]} rule
     * @param {string[]} rules
     * @param {string[]} rulesets
     * @param {number[]} pseudo
     * @param {number[]} points
     * @param {string[]} declarations
     * @return {object}
     */
    function parse (value, root, parent, rule, rules, rulesets, pseudo, points, declarations) {
    	var index = 0;
    	var offset = 0;
    	var length = pseudo;
    	var atrule = 0;
    	var property = 0;
    	var previous = 0;
    	var variable = 1;
    	var scanning = 1;
    	var ampersand = 1;
    	var character = 0;
    	var type = '';
    	var props = rules;
    	var children = rulesets;
    	var reference = rule;
    	var characters = type;

    	while (scanning)
    		switch (previous = character, character = next()) {
    			// (
    			case 40:
    				if (previous != 108 && charat(characters, length - 1) == 58) {
    					if (indexof(characters += replace(delimit(character), '&', '&\f'), '&\f') != -1)
    						ampersand = -1;
    					break
    				}
    			// " ' [
    			case 34: case 39: case 91:
    				characters += delimit(character);
    				break
    			// \t \n \r \s
    			case 9: case 10: case 13: case 32:
    				characters += whitespace(previous);
    				break
    			// \
    			case 92:
    				characters += escaping(caret() - 1, 7);
    				continue
    			// /
    			case 47:
    				switch (peek()) {
    					case 42: case 47:
    						append(comment(commenter(next(), caret()), root, parent), declarations);
    						break
    					default:
    						characters += '/';
    				}
    				break
    			// {
    			case 123 * variable:
    				points[index++] = strlen(characters) * ampersand;
    			// } ; \0
    			case 125 * variable: case 59: case 0:
    				switch (character) {
    					// \0 }
    					case 0: case 125: scanning = 0;
    					// ;
    					case 59 + offset: if (ampersand == -1) characters = replace(characters, /\f/g, '');
    						if (property > 0 && (strlen(characters) - length))
    							append(property > 32 ? declaration(characters + ';', rule, parent, length - 1) : declaration(replace(characters, ' ', '') + ';', rule, parent, length - 2), declarations);
    						break
    					// @ ;
    					case 59: characters += ';';
    					// { rule/at-rule
    					default:
    						append(reference = ruleset(characters, root, parent, index, offset, rules, points, type, props = [], children = [], length), rulesets);

    						if (character === 123)
    							if (offset === 0)
    								parse(characters, root, reference, reference, props, rulesets, length, points, children);
    							else
    								switch (atrule === 99 && charat(characters, 3) === 110 ? 100 : atrule) {
    									// d l m s
    									case 100: case 108: case 109: case 115:
    										parse(value, reference, reference, rule && append(ruleset(value, reference, reference, 0, 0, rules, points, type, rules, props = [], length), children), rules, children, length, points, rule ? props : children);
    										break
    									default:
    										parse(characters, reference, reference, reference, [''], children, 0, points, children);
    								}
    				}

    				index = offset = property = 0, variable = ampersand = 1, type = characters = '', length = pseudo;
    				break
    			// :
    			case 58:
    				length = 1 + strlen(characters), property = previous;
    			default:
    				if (variable < 1)
    					if (character == 123)
    						--variable;
    					else if (character == 125 && variable++ == 0 && prev() == 125)
    						continue

    				switch (characters += from(character), character * variable) {
    					// &
    					case 38:
    						ampersand = offset > 0 ? 1 : (characters += '\f', -1);
    						break
    					// ,
    					case 44:
    						points[index++] = (strlen(characters) - 1) * ampersand, ampersand = 1;
    						break
    					// @
    					case 64:
    						// -
    						if (peek() === 45)
    							characters += delimit(next());

    						atrule = peek(), offset = length = strlen(type = characters += identifier(caret())), character++;
    						break
    					// -
    					case 45:
    						if (previous === 45 && strlen(characters) == 2)
    							variable = 0;
    				}
    		}

    	return rulesets
    }

    /**
     * @param {string} value
     * @param {object} root
     * @param {object?} parent
     * @param {number} index
     * @param {number} offset
     * @param {string[]} rules
     * @param {number[]} points
     * @param {string} type
     * @param {string[]} props
     * @param {string[]} children
     * @param {number} length
     * @return {object}
     */
    function ruleset (value, root, parent, index, offset, rules, points, type, props, children, length) {
    	var post = offset - 1;
    	var rule = offset === 0 ? rules : [''];
    	var size = sizeof(rule);

    	for (var i = 0, j = 0, k = 0; i < index; ++i)
    		for (var x = 0, y = substr(value, post + 1, post = abs(j = points[i])), z = value; x < size; ++x)
    			if (z = trim(j > 0 ? rule[x] + ' ' + y : replace(y, /&\f/g, rule[x])))
    				props[k++] = z;

    	return node(value, root, parent, offset === 0 ? RULESET : type, props, children, length)
    }

    /**
     * @param {number} value
     * @param {object} root
     * @param {object?} parent
     * @return {object}
     */
    function comment (value, root, parent) {
    	return node(value, root, parent, COMMENT, from(char()), substr(value, 2, -2), 0)
    }

    /**
     * @param {string} value
     * @param {object} root
     * @param {object?} parent
     * @param {number} length
     * @return {object}
     */
    function declaration (value, root, parent, length) {
    	return node(value, root, parent, DECLARATION, substr(value, 0, length), substr(value, length + 1, -1), length)
    }

    /**
     * @param {object[]} children
     * @param {function} callback
     * @return {string}
     */
    function serialize (children, callback) {
    	var output = '';
    	var length = sizeof(children);

    	for (var i = 0; i < length; i++)
    		output += callback(children[i], i, children, callback) || '';

    	return output
    }

    /**
     * @param {object} element
     * @param {number} index
     * @param {object[]} children
     * @param {function} callback
     * @return {string}
     */
    function stringify (element, index, children, callback) {
    	switch (element.type) {
    		case LAYER: if (element.children.length) break
    		case IMPORT: case DECLARATION: return element.return = element.return || element.value
    		case COMMENT: return ''
    		case KEYFRAMES: return element.return = element.value + '{' + serialize(element.children, callback) + '}'
    		case RULESET: element.value = element.props.join(',');
    	}

    	return strlen(children = serialize(element.children, callback)) ? element.return = element.value + '{' + children + '}' : ''
    }

    /**
     * @param {function[]} collection
     * @return {function}
     */
    function middleware (collection) {
    	var length = sizeof(collection);

    	return function (element, index, children, callback) {
    		var output = '';

    		for (var i = 0; i < length; i++)
    			output += collection[i](element, index, children, callback) || '';

    		return output
    	}
    }

    /**
     * @param {function} callback
     * @return {function}
     */
    function rulesheet (callback) {
    	return function (element) {
    		if (!element.root)
    			if (element = element.return)
    				callback(element);
    	}
    }

    var weakMemoize = function weakMemoize(func) {
      // $FlowFixMe flow doesn't include all non-primitive types as allowed for weakmaps
      var cache = new WeakMap();
      return function (arg) {
        if (cache.has(arg)) {
          // $FlowFixMe
          return cache.get(arg);
        }

        var ret = func(arg);
        cache.set(arg, ret);
        return ret;
      };
    };

    var identifierWithPointTracking = function identifierWithPointTracking(begin, points, index) {
      var previous = 0;
      var character = 0;

      while (true) {
        previous = character;
        character = peek(); // &\f

        if (previous === 38 && character === 12) {
          points[index] = 1;
        }

        if (token(character)) {
          break;
        }

        next();
      }

      return slice(begin, position);
    };

    var toRules = function toRules(parsed, points) {
      // pretend we've started with a comma
      var index = -1;
      var character = 44;

      do {
        switch (token(character)) {
          case 0:
            // &\f
            if (character === 38 && peek() === 12) {
              // this is not 100% correct, we don't account for literal sequences here - like for example quoted strings
              // stylis inserts \f after & to know when & where it should replace this sequence with the context selector
              // and when it should just concatenate the outer and inner selectors
              // it's very unlikely for this sequence to actually appear in a different context, so we just leverage this fact here
              points[index] = 1;
            }

            parsed[index] += identifierWithPointTracking(position - 1, points, index);
            break;

          case 2:
            parsed[index] += delimit(character);
            break;

          case 4:
            // comma
            if (character === 44) {
              // colon
              parsed[++index] = peek() === 58 ? '&\f' : '';
              points[index] = parsed[index].length;
              break;
            }

          // fallthrough

          default:
            parsed[index] += from(character);
        }
      } while (character = next());

      return parsed;
    };

    var getRules = function getRules(value, points) {
      return dealloc(toRules(alloc(value), points));
    }; // WeakSet would be more appropriate, but only WeakMap is supported in IE11


    var fixedElements = /* #__PURE__ */new WeakMap();
    var compat = function compat(element) {
      if (element.type !== 'rule' || !element.parent || // positive .length indicates that this rule contains pseudo
      // negative .length indicates that this rule has been already prefixed
      element.length < 1) {
        return;
      }

      var value = element.value,
          parent = element.parent;
      var isImplicitRule = element.column === parent.column && element.line === parent.line;

      while (parent.type !== 'rule') {
        parent = parent.parent;
        if (!parent) return;
      } // short-circuit for the simplest case


      if (element.props.length === 1 && value.charCodeAt(0) !== 58
      /* colon */
      && !fixedElements.get(parent)) {
        return;
      } // if this is an implicitly inserted rule (the one eagerly inserted at the each new nested level)
      // then the props has already been manipulated beforehand as they that array is shared between it and its "rule parent"


      if (isImplicitRule) {
        return;
      }

      fixedElements.set(element, true);
      var points = [];
      var rules = getRules(value, points);
      var parentRules = parent.props;

      for (var i = 0, k = 0; i < rules.length; i++) {
        for (var j = 0; j < parentRules.length; j++, k++) {
          element.props[k] = points[i] ? rules[i].replace(/&\f/g, parentRules[j]) : parentRules[j] + " " + rules[i];
        }
      }
    };
    var removeLabel = function removeLabel(element) {
      if (element.type === 'decl') {
        var value = element.value;

        if ( // charcode for l
        value.charCodeAt(0) === 108 && // charcode for b
        value.charCodeAt(2) === 98) {
          // this ignores label
          element["return"] = '';
          element.value = '';
        }
      }
    };

    /* eslint-disable no-fallthrough */

    function prefix(value, length) {
      switch (hash(value, length)) {
        // color-adjust
        case 5103:
          return WEBKIT + 'print-' + value + value;
        // animation, animation-(delay|direction|duration|fill-mode|iteration-count|name|play-state|timing-function)

        case 5737:
        case 4201:
        case 3177:
        case 3433:
        case 1641:
        case 4457:
        case 2921: // text-decoration, filter, clip-path, backface-visibility, column, box-decoration-break

        case 5572:
        case 6356:
        case 5844:
        case 3191:
        case 6645:
        case 3005: // mask, mask-image, mask-(mode|clip|size), mask-(repeat|origin), mask-position, mask-composite,

        case 6391:
        case 5879:
        case 5623:
        case 6135:
        case 4599:
        case 4855: // background-clip, columns, column-(count|fill|gap|rule|rule-color|rule-style|rule-width|span|width)

        case 4215:
        case 6389:
        case 5109:
        case 5365:
        case 5621:
        case 3829:
          return WEBKIT + value + value;
        // appearance, user-select, transform, hyphens, text-size-adjust

        case 5349:
        case 4246:
        case 4810:
        case 6968:
        case 2756:
          return WEBKIT + value + MOZ + value + MS + value + value;
        // flex, flex-direction

        case 6828:
        case 4268:
          return WEBKIT + value + MS + value + value;
        // order

        case 6165:
          return WEBKIT + value + MS + 'flex-' + value + value;
        // align-items

        case 5187:
          return WEBKIT + value + replace(value, /(\w+).+(:[^]+)/, WEBKIT + 'box-$1$2' + MS + 'flex-$1$2') + value;
        // align-self

        case 5443:
          return WEBKIT + value + MS + 'flex-item-' + replace(value, /flex-|-self/, '') + value;
        // align-content

        case 4675:
          return WEBKIT + value + MS + 'flex-line-pack' + replace(value, /align-content|flex-|-self/, '') + value;
        // flex-shrink

        case 5548:
          return WEBKIT + value + MS + replace(value, 'shrink', 'negative') + value;
        // flex-basis

        case 5292:
          return WEBKIT + value + MS + replace(value, 'basis', 'preferred-size') + value;
        // flex-grow

        case 6060:
          return WEBKIT + 'box-' + replace(value, '-grow', '') + WEBKIT + value + MS + replace(value, 'grow', 'positive') + value;
        // transition

        case 4554:
          return WEBKIT + replace(value, /([^-])(transform)/g, '$1' + WEBKIT + '$2') + value;
        // cursor

        case 6187:
          return replace(replace(replace(value, /(zoom-|grab)/, WEBKIT + '$1'), /(image-set)/, WEBKIT + '$1'), value, '') + value;
        // background, background-image

        case 5495:
        case 3959:
          return replace(value, /(image-set\([^]*)/, WEBKIT + '$1' + '$`$1');
        // justify-content

        case 4968:
          return replace(replace(value, /(.+:)(flex-)?(.*)/, WEBKIT + 'box-pack:$3' + MS + 'flex-pack:$3'), /s.+-b[^;]+/, 'justify') + WEBKIT + value + value;
        // (margin|padding)-inline-(start|end)

        case 4095:
        case 3583:
        case 4068:
        case 2532:
          return replace(value, /(.+)-inline(.+)/, WEBKIT + '$1$2') + value;
        // (min|max)?(width|height|inline-size|block-size)

        case 8116:
        case 7059:
        case 5753:
        case 5535:
        case 5445:
        case 5701:
        case 4933:
        case 4677:
        case 5533:
        case 5789:
        case 5021:
        case 4765:
          // stretch, max-content, min-content, fill-available
          if (strlen(value) - 1 - length > 6) switch (charat(value, length + 1)) {
            // (m)ax-content, (m)in-content
            case 109:
              // -
              if (charat(value, length + 4) !== 45) break;
            // (f)ill-available, (f)it-content

            case 102:
              return replace(value, /(.+:)(.+)-([^]+)/, '$1' + WEBKIT + '$2-$3' + '$1' + MOZ + (charat(value, length + 3) == 108 ? '$3' : '$2-$3')) + value;
            // (s)tretch

            case 115:
              return ~indexof(value, 'stretch') ? prefix(replace(value, 'stretch', 'fill-available'), length) + value : value;
          }
          break;
        // position: sticky

        case 4949:
          // (s)ticky?
          if (charat(value, length + 1) !== 115) break;
        // display: (flex|inline-flex)

        case 6444:
          switch (charat(value, strlen(value) - 3 - (~indexof(value, '!important') && 10))) {
            // stic(k)y
            case 107:
              return replace(value, ':', ':' + WEBKIT) + value;
            // (inline-)?fl(e)x

            case 101:
              return replace(value, /(.+:)([^;!]+)(;|!.+)?/, '$1' + WEBKIT + (charat(value, 14) === 45 ? 'inline-' : '') + 'box$3' + '$1' + WEBKIT + '$2$3' + '$1' + MS + '$2box$3') + value;
          }

          break;
        // writing-mode

        case 5936:
          switch (charat(value, length + 11)) {
            // vertical-l(r)
            case 114:
              return WEBKIT + value + MS + replace(value, /[svh]\w+-[tblr]{2}/, 'tb') + value;
            // vertical-r(l)

            case 108:
              return WEBKIT + value + MS + replace(value, /[svh]\w+-[tblr]{2}/, 'tb-rl') + value;
            // horizontal(-)tb

            case 45:
              return WEBKIT + value + MS + replace(value, /[svh]\w+-[tblr]{2}/, 'lr') + value;
          }

          return WEBKIT + value + MS + value + value;
      }

      return value;
    }

    var prefixer = function prefixer(element, index, children, callback) {
      if (element.length > -1) if (!element["return"]) switch (element.type) {
        case DECLARATION:
          element["return"] = prefix(element.value, element.length);
          break;

        case KEYFRAMES:
          return serialize([copy$1(element, {
            value: replace(element.value, '@', '@' + WEBKIT)
          })], callback);

        case RULESET:
          if (element.length) return combine(element.props, function (value) {
            switch (match(value, /(::plac\w+|:read-\w+)/)) {
              // :read-(only|write)
              case ':read-only':
              case ':read-write':
                return serialize([copy$1(element, {
                  props: [replace(value, /:(read-\w+)/, ':' + MOZ + '$1')]
                })], callback);
              // :placeholder

              case '::placeholder':
                return serialize([copy$1(element, {
                  props: [replace(value, /:(plac\w+)/, ':' + WEBKIT + 'input-$1')]
                }), copy$1(element, {
                  props: [replace(value, /:(plac\w+)/, ':' + MOZ + '$1')]
                }), copy$1(element, {
                  props: [replace(value, /:(plac\w+)/, MS + 'input-$1')]
                })], callback);
            }

            return '';
          });
      }
    };

    var isBrowser$4 = typeof document !== 'undefined';
    var getServerStylisCache = isBrowser$4 ? undefined : weakMemoize(function () {
      return memoize$1(function () {
        var cache = {};
        return function (name) {
          return cache[name];
        };
      });
    });
    var defaultStylisPlugins = [prefixer];

    var createCache = function createCache(options) {
      var key = options.key;

      if (isBrowser$4 && key === 'css') {
        var ssrStyles = document.querySelectorAll("style[data-emotion]:not([data-s])"); // get SSRed styles out of the way of React's hydration
        // document.head is a safe place to move them to(though note document.head is not necessarily the last place they will be)
        // note this very very intentionally targets all style elements regardless of the key to ensure
        // that creating a cache works inside of render of a React component

        Array.prototype.forEach.call(ssrStyles, function (node) {
          // we want to only move elements which have a space in the data-emotion attribute value
          // because that indicates that it is an Emotion 11 server-side rendered style elements
          // while we will already ignore Emotion 11 client-side inserted styles because of the :not([data-s]) part in the selector
          // Emotion 10 client-side inserted styles did not have data-s (but importantly did not have a space in their data-emotion attributes)
          // so checking for the space ensures that loading Emotion 11 after Emotion 10 has inserted some styles
          // will not result in the Emotion 10 styles being destroyed
          var dataEmotionAttribute = node.getAttribute('data-emotion');

          if (dataEmotionAttribute.indexOf(' ') === -1) {
            return;
          }
          document.head.appendChild(node);
          node.setAttribute('data-s', '');
        });
      }

      var stylisPlugins = options.stylisPlugins || defaultStylisPlugins;

      var inserted = {};
      var container;
      var nodesToHydrate = [];

      if (isBrowser$4) {
        container = options.container || document.head;
        Array.prototype.forEach.call( // this means we will ignore elements which don't have a space in them which
        // means that the style elements we're looking at are only Emotion 11 server-rendered style elements
        document.querySelectorAll("style[data-emotion^=\"" + key + " \"]"), function (node) {
          var attrib = node.getAttribute("data-emotion").split(' '); // $FlowFixMe

          for (var i = 1; i < attrib.length; i++) {
            inserted[attrib[i]] = true;
          }

          nodesToHydrate.push(node);
        });
      }

      var _insert;

      var omnipresentPlugins = [compat, removeLabel];

      if (isBrowser$4) {
        var currentSheet;
        var finalizingPlugins = [stringify, rulesheet(function (rule) {
          currentSheet.insert(rule);
        })];
        var serializer = middleware(omnipresentPlugins.concat(stylisPlugins, finalizingPlugins));

        var stylis = function stylis(styles) {
          return serialize(compile(styles), serializer);
        };

        _insert = function insert(selector, serialized, sheet, shouldCache) {
          currentSheet = sheet;

          stylis(selector ? selector + "{" + serialized.styles + "}" : serialized.styles);

          if (shouldCache) {
            cache.inserted[serialized.name] = true;
          }
        };
      } else {
        var _finalizingPlugins = [stringify];

        var _serializer = middleware(omnipresentPlugins.concat(stylisPlugins, _finalizingPlugins));

        var _stylis = function _stylis(styles) {
          return serialize(compile(styles), _serializer);
        }; // $FlowFixMe


        var serverStylisCache = getServerStylisCache(stylisPlugins)(key);

        var getRules = function getRules(selector, serialized) {
          var name = serialized.name;

          if (serverStylisCache[name] === undefined) {
            serverStylisCache[name] = _stylis(selector ? selector + "{" + serialized.styles + "}" : serialized.styles);
          }

          return serverStylisCache[name];
        };

        _insert = function _insert(selector, serialized, sheet, shouldCache) {
          var name = serialized.name;
          var rules = getRules(selector, serialized);

          if (cache.compat === undefined) {
            // in regular mode, we don't set the styles on the inserted cache
            // since we don't need to and that would be wasting memory
            // we return them so that they are rendered in a style tag
            if (shouldCache) {
              cache.inserted[name] = true;
            }

            return rules;
          } else {
            // in compat mode, we put the styles on the inserted cache so
            // that emotion-server can pull out the styles
            // except when we don't want to cache it which was in Global but now
            // is nowhere but we don't want to do a major right now
            // and just in case we're going to leave the case here
            // it's also not affecting client side bundle size
            // so it's really not a big deal
            if (shouldCache) {
              cache.inserted[name] = rules;
            } else {
              return rules;
            }
          }
        };
      }

      var cache = {
        key: key,
        sheet: new StyleSheet({
          key: key,
          container: container,
          nonce: options.nonce,
          speedy: options.speedy,
          prepend: options.prepend,
          insertionPoint: options.insertionPoint
        }),
        nonce: options.nonce,
        inserted: inserted,
        registered: {},
        insert: _insert
      };
      cache.sheet.hydrate(nodesToHydrate);
      return cache;
    };

    var reactIs$1 = {exports: {}};

    var reactIs_production_min = {};

    /** @license React v16.13.1
     * react-is.production.min.js
     *
     * Copyright (c) Facebook, Inc. and its affiliates.
     *
     * This source code is licensed under the MIT license found in the
     * LICENSE file in the root directory of this source tree.
     */
    var b="function"===typeof Symbol&&Symbol.for,c=b?Symbol.for("react.element"):60103,d=b?Symbol.for("react.portal"):60106,e$1=b?Symbol.for("react.fragment"):60107,f=b?Symbol.for("react.strict_mode"):60108,g=b?Symbol.for("react.profiler"):60114,h$2=b?Symbol.for("react.provider"):60109,k$1=b?Symbol.for("react.context"):60110,l$1=b?Symbol.for("react.async_mode"):60111,m$1=b?Symbol.for("react.concurrent_mode"):60111,n$2=b?Symbol.for("react.forward_ref"):60112,p$2=b?Symbol.for("react.suspense"):60113,q$2=b?
    Symbol.for("react.suspense_list"):60120,r$5=b?Symbol.for("react.memo"):60115,t$2=b?Symbol.for("react.lazy"):60116,v$1=b?Symbol.for("react.block"):60121,w$1=b?Symbol.for("react.fundamental"):60117,x=b?Symbol.for("react.responder"):60118,y=b?Symbol.for("react.scope"):60119;
    function z(a){if("object"===typeof a&&null!==a){var u=a.$$typeof;switch(u){case c:switch(a=a.type,a){case l$1:case m$1:case e$1:case g:case f:case p$2:return a;default:switch(a=a&&a.$$typeof,a){case k$1:case n$2:case t$2:case r$5:case h$2:return a;default:return u}}case d:return u}}}function A(a){return z(a)===m$1}reactIs_production_min.AsyncMode=l$1;reactIs_production_min.ConcurrentMode=m$1;reactIs_production_min.ContextConsumer=k$1;reactIs_production_min.ContextProvider=h$2;reactIs_production_min.Element=c;reactIs_production_min.ForwardRef=n$2;reactIs_production_min.Fragment=e$1;reactIs_production_min.Lazy=t$2;reactIs_production_min.Memo=r$5;reactIs_production_min.Portal=d;
    reactIs_production_min.Profiler=g;reactIs_production_min.StrictMode=f;reactIs_production_min.Suspense=p$2;reactIs_production_min.isAsyncMode=function(a){return A(a)||z(a)===l$1};reactIs_production_min.isConcurrentMode=A;reactIs_production_min.isContextConsumer=function(a){return z(a)===k$1};reactIs_production_min.isContextProvider=function(a){return z(a)===h$2};reactIs_production_min.isElement=function(a){return "object"===typeof a&&null!==a&&a.$$typeof===c};reactIs_production_min.isForwardRef=function(a){return z(a)===n$2};reactIs_production_min.isFragment=function(a){return z(a)===e$1};reactIs_production_min.isLazy=function(a){return z(a)===t$2};
    reactIs_production_min.isMemo=function(a){return z(a)===r$5};reactIs_production_min.isPortal=function(a){return z(a)===d};reactIs_production_min.isProfiler=function(a){return z(a)===g};reactIs_production_min.isStrictMode=function(a){return z(a)===f};reactIs_production_min.isSuspense=function(a){return z(a)===p$2};
    reactIs_production_min.isValidElementType=function(a){return "string"===typeof a||"function"===typeof a||a===e$1||a===m$1||a===g||a===f||a===p$2||a===q$2||"object"===typeof a&&null!==a&&(a.$$typeof===t$2||a.$$typeof===r$5||a.$$typeof===h$2||a.$$typeof===k$1||a.$$typeof===n$2||a.$$typeof===w$1||a.$$typeof===x||a.$$typeof===y||a.$$typeof===v$1)};reactIs_production_min.typeOf=z;

    {
      reactIs$1.exports = reactIs_production_min;
    }

    var reactIsExports = reactIs$1.exports;

    var reactIs = reactIsExports;
    var FORWARD_REF_STATICS = {
      '$$typeof': true,
      render: true,
      defaultProps: true,
      displayName: true,
      propTypes: true
    };
    var MEMO_STATICS = {
      '$$typeof': true,
      compare: true,
      defaultProps: true,
      displayName: true,
      propTypes: true,
      type: true
    };
    var TYPE_STATICS = {};
    TYPE_STATICS[reactIs.ForwardRef] = FORWARD_REF_STATICS;
    TYPE_STATICS[reactIs.Memo] = MEMO_STATICS;

    var isBrowser$3 = typeof document !== 'undefined';
    function getRegisteredStyles(registered, registeredStyles, classNames) {
      var rawClassName = '';
      classNames.split(' ').forEach(function (className) {
        if (registered[className] !== undefined) {
          registeredStyles.push(registered[className] + ";");
        } else {
          rawClassName += className + " ";
        }
      });
      return rawClassName;
    }
    var registerStyles = function registerStyles(cache, serialized, isStringTag) {
      var className = cache.key + "-" + serialized.name;

      if ( // we only need to add the styles to the registered cache if the
      // class name could be used further down
      // the tree but if it's a string tag, we know it won't
      // so we don't have to add it to registered cache.
      // this improves memory usage since we can avoid storing the whole style string
      (isStringTag === false || // we need to always store it if we're in compat mode and
      // in node since emotion-server relies on whether a style is in
      // the registered cache to know whether a style is global or not
      // also, note that this check will be dead code eliminated in the browser
      isBrowser$3 === false && cache.compat !== undefined) && cache.registered[className] === undefined) {
        cache.registered[className] = serialized.styles;
      }
    };
    var insertStyles = function insertStyles(cache, serialized, isStringTag) {
      registerStyles(cache, serialized, isStringTag);
      var className = cache.key + "-" + serialized.name;

      if (cache.inserted[serialized.name] === undefined) {
        var stylesForSSR = '';
        var current = serialized;

        do {
          var maybeStyles = cache.insert(serialized === current ? "." + className : '', current, cache.sheet, true);

          if (!isBrowser$3 && maybeStyles !== undefined) {
            stylesForSSR += maybeStyles;
          }

          current = current.next;
        } while (current !== undefined);

        if (!isBrowser$3 && stylesForSSR.length !== 0) {
          return stylesForSSR;
        }
      }
    };

    /* eslint-disable */
    // Inspired by https://github.com/garycourt/murmurhash-js
    // Ported from https://github.com/aappleby/smhasher/blob/61a0530f28277f2e850bfc39600ce61d02b518de/src/MurmurHash2.cpp#L37-L86
    function murmur2(str) {
      // 'm' and 'r' are mixing constants generated offline.
      // They're not really 'magic', they just happen to work well.
      // const m = 0x5bd1e995;
      // const r = 24;
      // Initialize the hash
      var h = 0; // Mix 4 bytes at a time into the hash

      var k,
          i = 0,
          len = str.length;

      for (; len >= 4; ++i, len -= 4) {
        k = str.charCodeAt(i) & 0xff | (str.charCodeAt(++i) & 0xff) << 8 | (str.charCodeAt(++i) & 0xff) << 16 | (str.charCodeAt(++i) & 0xff) << 24;
        k =
        /* Math.imul(k, m): */
        (k & 0xffff) * 0x5bd1e995 + ((k >>> 16) * 0xe995 << 16);
        k ^=
        /* k >>> r: */
        k >>> 24;
        h =
        /* Math.imul(k, m): */
        (k & 0xffff) * 0x5bd1e995 + ((k >>> 16) * 0xe995 << 16) ^
        /* Math.imul(h, m): */
        (h & 0xffff) * 0x5bd1e995 + ((h >>> 16) * 0xe995 << 16);
      } // Handle the last few bytes of the input array


      switch (len) {
        case 3:
          h ^= (str.charCodeAt(i + 2) & 0xff) << 16;

        case 2:
          h ^= (str.charCodeAt(i + 1) & 0xff) << 8;

        case 1:
          h ^= str.charCodeAt(i) & 0xff;
          h =
          /* Math.imul(h, m): */
          (h & 0xffff) * 0x5bd1e995 + ((h >>> 16) * 0xe995 << 16);
      } // Do a few final mixes of the hash to ensure the last few
      // bytes are well-incorporated.


      h ^= h >>> 13;
      h =
      /* Math.imul(h, m): */
      (h & 0xffff) * 0x5bd1e995 + ((h >>> 16) * 0xe995 << 16);
      return ((h ^ h >>> 15) >>> 0).toString(36);
    }

    var unitlessKeys = {
      animationIterationCount: 1,
      aspectRatio: 1,
      borderImageOutset: 1,
      borderImageSlice: 1,
      borderImageWidth: 1,
      boxFlex: 1,
      boxFlexGroup: 1,
      boxOrdinalGroup: 1,
      columnCount: 1,
      columns: 1,
      flex: 1,
      flexGrow: 1,
      flexPositive: 1,
      flexShrink: 1,
      flexNegative: 1,
      flexOrder: 1,
      gridRow: 1,
      gridRowEnd: 1,
      gridRowSpan: 1,
      gridRowStart: 1,
      gridColumn: 1,
      gridColumnEnd: 1,
      gridColumnSpan: 1,
      gridColumnStart: 1,
      msGridRow: 1,
      msGridRowSpan: 1,
      msGridColumn: 1,
      msGridColumnSpan: 1,
      fontWeight: 1,
      lineHeight: 1,
      opacity: 1,
      order: 1,
      orphans: 1,
      tabSize: 1,
      widows: 1,
      zIndex: 1,
      zoom: 1,
      WebkitLineClamp: 1,
      // SVG-related properties
      fillOpacity: 1,
      floodOpacity: 1,
      stopOpacity: 1,
      strokeDasharray: 1,
      strokeDashoffset: 1,
      strokeMiterlimit: 1,
      strokeOpacity: 1,
      strokeWidth: 1
    };

    var hyphenateRegex = /[A-Z]|^ms/g;
    var animationRegex = /_EMO_([^_]+?)_([^]*?)_EMO_/g;

    var isCustomProperty = function isCustomProperty(property) {
      return property.charCodeAt(1) === 45;
    };

    var isProcessableValue = function isProcessableValue(value) {
      return value != null && typeof value !== 'boolean';
    };

    var processStyleName = /* #__PURE__ */memoize$1(function (styleName) {
      return isCustomProperty(styleName) ? styleName : styleName.replace(hyphenateRegex, '-$&').toLowerCase();
    });

    var processStyleValue = function processStyleValue(key, value) {
      switch (key) {
        case 'animation':
        case 'animationName':
          {
            if (typeof value === 'string') {
              return value.replace(animationRegex, function (match, p1, p2) {
                cursor = {
                  name: p1,
                  styles: p2,
                  next: cursor
                };
                return p1;
              });
            }
          }
      }

      if (unitlessKeys[key] !== 1 && !isCustomProperty(key) && typeof value === 'number' && value !== 0) {
        return value + 'px';
      }

      return value;
    };

    var noComponentSelectorMessage = 'Component selectors can only be used in conjunction with ' + '@emotion/babel-plugin, the swc Emotion plugin, or another Emotion-aware ' + 'compiler transform.';

    function handleInterpolation(mergedProps, registered, interpolation) {
      if (interpolation == null) {
        return '';
      }

      if (interpolation.__emotion_styles !== undefined) {

        return interpolation;
      }

      switch (typeof interpolation) {
        case 'boolean':
          {
            return '';
          }

        case 'object':
          {
            if (interpolation.anim === 1) {
              cursor = {
                name: interpolation.name,
                styles: interpolation.styles,
                next: cursor
              };
              return interpolation.name;
            }

            if (interpolation.styles !== undefined) {
              var next = interpolation.next;

              if (next !== undefined) {
                // not the most efficient thing ever but this is a pretty rare case
                // and there will be very few iterations of this generally
                while (next !== undefined) {
                  cursor = {
                    name: next.name,
                    styles: next.styles,
                    next: cursor
                  };
                  next = next.next;
                }
              }

              var styles = interpolation.styles + ";";

              return styles;
            }

            return createStringFromObject(mergedProps, registered, interpolation);
          }

        case 'function':
          {
            if (mergedProps !== undefined) {
              var previousCursor = cursor;
              var result = interpolation(mergedProps);
              cursor = previousCursor;
              return handleInterpolation(mergedProps, registered, result);
            }

            break;
          }
      } // finalize string values (regular strings and functions interpolated into css calls)


      if (registered == null) {
        return interpolation;
      }

      var cached = registered[interpolation];
      return cached !== undefined ? cached : interpolation;
    }

    function createStringFromObject(mergedProps, registered, obj) {
      var string = '';

      if (Array.isArray(obj)) {
        for (var i = 0; i < obj.length; i++) {
          string += handleInterpolation(mergedProps, registered, obj[i]) + ";";
        }
      } else {
        for (var _key in obj) {
          var value = obj[_key];

          if (typeof value !== 'object') {
            if (registered != null && registered[value] !== undefined) {
              string += _key + "{" + registered[value] + "}";
            } else if (isProcessableValue(value)) {
              string += processStyleName(_key) + ":" + processStyleValue(_key, value) + ";";
            }
          } else {
            if (_key === 'NO_COMPONENT_SELECTOR' && "production" !== 'production') {
              throw new Error(noComponentSelectorMessage);
            }

            if (Array.isArray(value) && typeof value[0] === 'string' && (registered == null || registered[value[0]] === undefined)) {
              for (var _i = 0; _i < value.length; _i++) {
                if (isProcessableValue(value[_i])) {
                  string += processStyleName(_key) + ":" + processStyleValue(_key, value[_i]) + ";";
                }
              }
            } else {
              var interpolated = handleInterpolation(mergedProps, registered, value);

              switch (_key) {
                case 'animation':
                case 'animationName':
                  {
                    string += processStyleName(_key) + ":" + interpolated + ";";
                    break;
                  }

                default:
                  {

                    string += _key + "{" + interpolated + "}";
                  }
              }
            }
          }
        }
      }

      return string;
    }

    var labelPattern = /label:\s*([^\s;\n{]+)\s*(;|$)/g;
    // keyframes are stored on the SerializedStyles object as a linked list


    var cursor;
    var serializeStyles = function serializeStyles(args, registered, mergedProps) {
      if (args.length === 1 && typeof args[0] === 'object' && args[0] !== null && args[0].styles !== undefined) {
        return args[0];
      }

      var stringMode = true;
      var styles = '';
      cursor = undefined;
      var strings = args[0];

      if (strings == null || strings.raw === undefined) {
        stringMode = false;
        styles += handleInterpolation(mergedProps, registered, strings);
      } else {

        styles += strings[0];
      } // we start at 1 since we've already handled the first arg


      for (var i = 1; i < args.length; i++) {
        styles += handleInterpolation(mergedProps, registered, args[i]);

        if (stringMode) {

          styles += strings[i];
        }
      }


      labelPattern.lastIndex = 0;
      var identifierName = '';
      var match; // https://esbench.com/bench/5b809c2cf2949800a0f61fb5

      while ((match = labelPattern.exec(styles)) !== null) {
        identifierName += '-' + // $FlowFixMe we know it's not null
        match[1];
      }

      var name = murmur2(styles) + identifierName;

      return {
        name: name,
        styles: styles,
        next: cursor
      };
    };

    var isBrowser$2 = typeof document !== 'undefined';

    var syncFallback = function syncFallback(create) {
      return create();
    };

    var useInsertionEffect = React['useInsertion' + 'Effect'] ? React['useInsertion' + 'Effect'] : false;
    var useInsertionEffectAlwaysWithSyncFallback = !isBrowser$2 ? syncFallback : useInsertionEffect || syncFallback;
    var useInsertionEffectWithLayoutFallback = useInsertionEffect || reactExports.useLayoutEffect;

    var isBrowser$1 = typeof document !== 'undefined';

    var EmotionCacheContext = /* #__PURE__ */reactExports.createContext( // we're doing this to avoid preconstruct's dead code elimination in this one case
    // because this module is primarily intended for the browser and node
    // but it's also required in react native and similar environments sometimes
    // and we could have a special build just for that
    // but this is much easier and the native packages
    // might use a different theme context in the future anyway
    typeof HTMLElement !== 'undefined' ? /* #__PURE__ */createCache({
      key: 'css'
    }) : null);

    EmotionCacheContext.Provider;

    var withEmotionCache = function withEmotionCache(func) {
      // $FlowFixMe
      return /*#__PURE__*/reactExports.forwardRef(function (props, ref) {
        // the cache will never be null in the browser
        var cache = reactExports.useContext(EmotionCacheContext);
        return func(props, cache, ref);
      });
    };

    if (!isBrowser$1) {
      withEmotionCache = function withEmotionCache(func) {
        return function (props) {
          var cache = reactExports.useContext(EmotionCacheContext);

          if (cache === null) {
            // yes, we're potentially creating this on every render
            // it doesn't actually matter though since it's only on the server
            // so there will only every be a single render
            // that could change in the future because of suspense and etc. but for now,
            // this works and i don't want to optimise for a future thing that we aren't sure about
            cache = createCache({
              key: 'css'
            });
            return /*#__PURE__*/reactExports.createElement(EmotionCacheContext.Provider, {
              value: cache
            }, func(props, cache));
          } else {
            return func(props, cache);
          }
        };
      };
    }

    var ThemeContext$2 = /* #__PURE__ */reactExports.createContext({});

    // initial render from browser, insertBefore context.sheet.tags[0] or if a style hasn't been inserted there yet, appendChild
    // initial client-side render from SSR, use place of hydrating tag

    var Global = /* #__PURE__ */withEmotionCache(function (props, cache) {

      var styles = props.styles;
      var serialized = serializeStyles([styles], undefined, reactExports.useContext(ThemeContext$2));

      if (!isBrowser$1) {
        var _ref;

        var serializedNames = serialized.name;
        var serializedStyles = serialized.styles;
        var next = serialized.next;

        while (next !== undefined) {
          serializedNames += ' ' + next.name;
          serializedStyles += next.styles;
          next = next.next;
        }

        var shouldCache = cache.compat === true;
        var rules = cache.insert("", {
          name: serializedNames,
          styles: serializedStyles
        }, cache.sheet, shouldCache);

        if (shouldCache) {
          return null;
        }

        return /*#__PURE__*/reactExports.createElement("style", (_ref = {}, _ref["data-emotion"] = cache.key + "-global " + serializedNames, _ref.dangerouslySetInnerHTML = {
          __html: rules
        }, _ref.nonce = cache.sheet.nonce, _ref));
      } // yes, i know these hooks are used conditionally
      // but it is based on a constant that will never change at runtime
      // it's effectively like having two implementations and switching them out
      // so it's not actually breaking anything


      var sheetRef = reactExports.useRef();
      useInsertionEffectWithLayoutFallback(function () {
        var key = cache.key + "-global"; // use case of https://github.com/emotion-js/emotion/issues/2675

        var sheet = new cache.sheet.constructor({
          key: key,
          nonce: cache.sheet.nonce,
          container: cache.sheet.container,
          speedy: cache.sheet.isSpeedy
        });
        var rehydrating = false; // $FlowFixMe

        var node = document.querySelector("style[data-emotion=\"" + key + " " + serialized.name + "\"]");

        if (cache.sheet.tags.length) {
          sheet.before = cache.sheet.tags[0];
        }

        if (node !== null) {
          rehydrating = true; // clear the hash so this node won't be recognizable as rehydratable by other <Global/>s

          node.setAttribute('data-emotion', key);
          sheet.hydrate([node]);
        }

        sheetRef.current = [sheet, rehydrating];
        return function () {
          sheet.flush();
        };
      }, [cache]);
      useInsertionEffectWithLayoutFallback(function () {
        var sheetRefCurrent = sheetRef.current;
        var sheet = sheetRefCurrent[0],
            rehydrating = sheetRefCurrent[1];

        if (rehydrating) {
          sheetRefCurrent[1] = false;
          return;
        }

        if (serialized.next !== undefined) {
          // insert keyframes
          insertStyles(cache, serialized.next, true);
        }

        if (sheet.tags.length) {
          // if this doesn't exist then it will be null so the style element will be appended
          var element = sheet.tags[sheet.tags.length - 1].nextElementSibling;
          sheet.before = element;
          sheet.flush();
        }

        cache.insert("", serialized, sheet, false);
      }, [cache, serialized.name]);
      return null;
    });

    var testOmitPropsOnStringTag = isPropValid;

    var testOmitPropsOnComponent = function testOmitPropsOnComponent(key) {
      return key !== 'theme';
    };

    var getDefaultShouldForwardProp = function getDefaultShouldForwardProp(tag) {
      return typeof tag === 'string' && // 96 is one less than the char code
      // for "a" so this is checking that
      // it's a lowercase character
      tag.charCodeAt(0) > 96 ? testOmitPropsOnStringTag : testOmitPropsOnComponent;
    };
    var composeShouldForwardProps = function composeShouldForwardProps(tag, options, isReal) {
      var shouldForwardProp;

      if (options) {
        var optionsShouldForwardProp = options.shouldForwardProp;
        shouldForwardProp = tag.__emotion_forwardProp && optionsShouldForwardProp ? function (propName) {
          return tag.__emotion_forwardProp(propName) && optionsShouldForwardProp(propName);
        } : optionsShouldForwardProp;
      }

      if (typeof shouldForwardProp !== 'function' && isReal) {
        shouldForwardProp = tag.__emotion_forwardProp;
      }

      return shouldForwardProp;
    };
    var isBrowser = typeof document !== 'undefined';

    var Insertion = function Insertion(_ref) {
      var cache = _ref.cache,
          serialized = _ref.serialized,
          isStringTag = _ref.isStringTag;
      registerStyles(cache, serialized, isStringTag);
      var rules = useInsertionEffectAlwaysWithSyncFallback(function () {
        return insertStyles(cache, serialized, isStringTag);
      });

      if (!isBrowser && rules !== undefined) {
        var _ref2;

        var serializedNames = serialized.name;
        var next = serialized.next;

        while (next !== undefined) {
          serializedNames += ' ' + next.name;
          next = next.next;
        }

        return /*#__PURE__*/reactExports.createElement("style", (_ref2 = {}, _ref2["data-emotion"] = cache.key + " " + serializedNames, _ref2.dangerouslySetInnerHTML = {
          __html: rules
        }, _ref2.nonce = cache.sheet.nonce, _ref2));
      }

      return null;
    };

    var createStyled$1 = function createStyled(tag, options) {

      var isReal = tag.__emotion_real === tag;
      var baseTag = isReal && tag.__emotion_base || tag;
      var identifierName;
      var targetClassName;

      if (options !== undefined) {
        identifierName = options.label;
        targetClassName = options.target;
      }

      var shouldForwardProp = composeShouldForwardProps(tag, options, isReal);
      var defaultShouldForwardProp = shouldForwardProp || getDefaultShouldForwardProp(baseTag);
      var shouldUseAs = !defaultShouldForwardProp('as');
      return function () {
        var args = arguments;
        var styles = isReal && tag.__emotion_styles !== undefined ? tag.__emotion_styles.slice(0) : [];

        if (identifierName !== undefined) {
          styles.push("label:" + identifierName + ";");
        }

        if (args[0] == null || args[0].raw === undefined) {
          styles.push.apply(styles, args);
        } else {

          styles.push(args[0][0]);
          var len = args.length;
          var i = 1;

          for (; i < len; i++) {

            styles.push(args[i], args[0][i]);
          }
        } // $FlowFixMe: we need to cast StatelessFunctionalComponent to our PrivateStyledComponent class


        var Styled = withEmotionCache(function (props, cache, ref) {
          var FinalTag = shouldUseAs && props.as || baseTag;
          var className = '';
          var classInterpolations = [];
          var mergedProps = props;

          if (props.theme == null) {
            mergedProps = {};

            for (var key in props) {
              mergedProps[key] = props[key];
            }

            mergedProps.theme = reactExports.useContext(ThemeContext$2);
          }

          if (typeof props.className === 'string') {
            className = getRegisteredStyles(cache.registered, classInterpolations, props.className);
          } else if (props.className != null) {
            className = props.className + " ";
          }

          var serialized = serializeStyles(styles.concat(classInterpolations), cache.registered, mergedProps);
          className += cache.key + "-" + serialized.name;

          if (targetClassName !== undefined) {
            className += " " + targetClassName;
          }

          var finalShouldForwardProp = shouldUseAs && shouldForwardProp === undefined ? getDefaultShouldForwardProp(FinalTag) : defaultShouldForwardProp;
          var newProps = {};

          for (var _key in props) {
            if (shouldUseAs && _key === 'as') continue;

            if ( // $FlowFixMe
            finalShouldForwardProp(_key)) {
              newProps[_key] = props[_key];
            }
          }

          newProps.className = className;
          newProps.ref = ref;
          return /*#__PURE__*/reactExports.createElement(reactExports.Fragment, null, /*#__PURE__*/reactExports.createElement(Insertion, {
            cache: cache,
            serialized: serialized,
            isStringTag: typeof FinalTag === 'string'
          }), /*#__PURE__*/reactExports.createElement(FinalTag, newProps));
        });
        Styled.displayName = identifierName !== undefined ? identifierName : "Styled(" + (typeof baseTag === 'string' ? baseTag : baseTag.displayName || baseTag.name || 'Component') + ")";
        Styled.defaultProps = tag.defaultProps;
        Styled.__emotion_real = Styled;
        Styled.__emotion_base = baseTag;
        Styled.__emotion_styles = styles;
        Styled.__emotion_forwardProp = shouldForwardProp;
        Object.defineProperty(Styled, 'toString', {
          value: function value() {
            if (targetClassName === undefined && "production" !== 'production') {
              return 'NO_COMPONENT_SELECTOR';
            } // $FlowFixMe: coerce undefined to string


            return "." + targetClassName;
          }
        });

        Styled.withComponent = function (nextTag, nextOptions) {
          return createStyled(nextTag, _extends$3({}, options, nextOptions, {
            shouldForwardProp: composeShouldForwardProps(Styled, nextOptions, true)
          })).apply(void 0, styles);
        };

        return Styled;
      };
    };

    var tags = ['a', 'abbr', 'address', 'area', 'article', 'aside', 'audio', 'b', 'base', 'bdi', 'bdo', 'big', 'blockquote', 'body', 'br', 'button', 'canvas', 'caption', 'cite', 'code', 'col', 'colgroup', 'data', 'datalist', 'dd', 'del', 'details', 'dfn', 'dialog', 'div', 'dl', 'dt', 'em', 'embed', 'fieldset', 'figcaption', 'figure', 'footer', 'form', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head', 'header', 'hgroup', 'hr', 'html', 'i', 'iframe', 'img', 'input', 'ins', 'kbd', 'keygen', 'label', 'legend', 'li', 'link', 'main', 'map', 'mark', 'marquee', 'menu', 'menuitem', 'meta', 'meter', 'nav', 'noscript', 'object', 'ol', 'optgroup', 'option', 'output', 'p', 'param', 'picture', 'pre', 'progress', 'q', 'rp', 'rt', 'ruby', 's', 'samp', 'script', 'section', 'select', 'small', 'source', 'span', 'strong', 'style', 'sub', 'summary', 'sup', 'table', 'tbody', 'td', 'textarea', 'tfoot', 'th', 'thead', 'time', 'title', 'tr', 'track', 'u', 'ul', 'var', 'video', 'wbr', // SVG
    'circle', 'clipPath', 'defs', 'ellipse', 'foreignObject', 'g', 'image', 'line', 'linearGradient', 'mask', 'path', 'pattern', 'polygon', 'polyline', 'radialGradient', 'rect', 'stop', 'svg', 'text', 'tspan'];

    var newStyled = createStyled$1.bind();
    tags.forEach(function (tagName) {
      // $FlowFixMe: we can ignore this because its exposed type is defined by the CreateStyled type
      newStyled[tagName] = newStyled(tagName);
    });

    if (typeof document === 'object') {
      createCache({
        key: 'css',
        prepend: true
      });
    }

    function isEmpty$3(obj) {
      return obj === undefined || obj === null || Object.keys(obj).length === 0;
    }
    function GlobalStyles$2(props) {
      const {
        styles,
        defaultTheme = {}
      } = props;
      const globalStyles = typeof styles === 'function' ? themeInput => styles(isEmpty$3(themeInput) ? defaultTheme : themeInput) : styles;
      return /*#__PURE__*/jsxRuntimeExports.jsx(Global, {
        styles: globalStyles
      });
    }

    /**
     * @mui/styled-engine v5.13.2
     *
     * @license MIT
     * This source code is licensed under the MIT license found in the
     * LICENSE file in the root directory of this source tree.
     */
    /* eslint-disable no-underscore-dangle */
    function styled$1(tag, options) {
      const stylesFactory = newStyled(tag, options);
      return stylesFactory;
    }

    // eslint-disable-next-line @typescript-eslint/naming-convention
    const internal_processStyles = (tag, processor) => {
      // Emotion attaches all the styles as `__emotion_styles`.
      // Ref: https://github.com/emotion-js/emotion/blob/16d971d0da229596d6bcc39d282ba9753c9ee7cf/packages/styled/src/base.js#L186
      if (Array.isArray(tag.__emotion_styles)) {
        tag.__emotion_styles = processor(tag.__emotion_styles);
      }
    };

    function _extends$2() {
      _extends$2 = Object.assign ? Object.assign.bind() : function (target) {
        for (var i = 1; i < arguments.length; i++) {
          var source = arguments[i];
          for (var key in source) {
            if (Object.prototype.hasOwnProperty.call(source, key)) {
              target[key] = source[key];
            }
          }
        }
        return target;
      };
      return _extends$2.apply(this, arguments);
    }

    function _objectWithoutPropertiesLoose$1(source, excluded) {
      if (source == null) return {};
      var target = {};
      var sourceKeys = Object.keys(source);
      var key, i;
      for (i = 0; i < sourceKeys.length; i++) {
        key = sourceKeys[i];
        if (excluded.indexOf(key) >= 0) continue;
        target[key] = source[key];
      }
      return target;
    }

    const _excluded$h = ["values", "unit", "step"];
    const sortBreakpointsValues = values => {
      const breakpointsAsArray = Object.keys(values).map(key => ({
        key,
        val: values[key]
      })) || [];
      // Sort in ascending order
      breakpointsAsArray.sort((breakpoint1, breakpoint2) => breakpoint1.val - breakpoint2.val);
      return breakpointsAsArray.reduce((acc, obj) => {
        return _extends$2({}, acc, {
          [obj.key]: obj.val
        });
      }, {});
    };

    // Keep in mind that @media is inclusive by the CSS specification.
    function createBreakpoints(breakpoints) {
      const {
          // The breakpoint **start** at this value.
          // For instance with the first breakpoint xs: [xs, sm).
          values = {
            xs: 0,
            // phone
            sm: 600,
            // tablet
            md: 900,
            // small laptop
            lg: 1200,
            // desktop
            xl: 1536 // large screen
          },

          unit = 'px',
          step = 5
        } = breakpoints,
        other = _objectWithoutPropertiesLoose$1(breakpoints, _excluded$h);
      const sortedValues = sortBreakpointsValues(values);
      const keys = Object.keys(sortedValues);
      function up(key) {
        const value = typeof values[key] === 'number' ? values[key] : key;
        return `@media (min-width:${value}${unit})`;
      }
      function down(key) {
        const value = typeof values[key] === 'number' ? values[key] : key;
        return `@media (max-width:${value - step / 100}${unit})`;
      }
      function between(start, end) {
        const endIndex = keys.indexOf(end);
        return `@media (min-width:${typeof values[start] === 'number' ? values[start] : start}${unit}) and ` + `(max-width:${(endIndex !== -1 && typeof values[keys[endIndex]] === 'number' ? values[keys[endIndex]] : end) - step / 100}${unit})`;
      }
      function only(key) {
        if (keys.indexOf(key) + 1 < keys.length) {
          return between(key, keys[keys.indexOf(key) + 1]);
        }
        return up(key);
      }
      function not(key) {
        // handle first and last key separately, for better readability
        const keyIndex = keys.indexOf(key);
        if (keyIndex === 0) {
          return up(keys[1]);
        }
        if (keyIndex === keys.length - 1) {
          return down(keys[keyIndex]);
        }
        return between(key, keys[keys.indexOf(key) + 1]).replace('@media', '@media not all and');
      }
      return _extends$2({
        keys,
        values: sortedValues,
        up,
        down,
        between,
        only,
        not,
        unit
      }, other);
    }

    const shape = {
      borderRadius: 4
    };

    function merge(acc, item) {
      if (!item) {
        return acc;
      }
      return deepmerge(acc, item, {
        clone: false // No need to clone deep, it's way faster.
      });
    }

    // The breakpoint **start** at this value.
    // For instance with the first breakpoint xs: [xs, sm[.
    const values = {
      xs: 0,
      // phone
      sm: 600,
      // tablet
      md: 900,
      // small laptop
      lg: 1200,
      // desktop
      xl: 1536 // large screen
    };

    const defaultBreakpoints = {
      // Sorted ASC by size. That's important.
      // It can't be configured as it's used statically for propTypes.
      keys: ['xs', 'sm', 'md', 'lg', 'xl'],
      up: key => `@media (min-width:${values[key]}px)`
    };
    function handleBreakpoints(props, propValue, styleFromPropValue) {
      const theme = props.theme || {};
      if (Array.isArray(propValue)) {
        const themeBreakpoints = theme.breakpoints || defaultBreakpoints;
        return propValue.reduce((acc, item, index) => {
          acc[themeBreakpoints.up(themeBreakpoints.keys[index])] = styleFromPropValue(propValue[index]);
          return acc;
        }, {});
      }
      if (typeof propValue === 'object') {
        const themeBreakpoints = theme.breakpoints || defaultBreakpoints;
        return Object.keys(propValue).reduce((acc, breakpoint) => {
          // key is breakpoint
          if (Object.keys(themeBreakpoints.values || values).indexOf(breakpoint) !== -1) {
            const mediaKey = themeBreakpoints.up(breakpoint);
            acc[mediaKey] = styleFromPropValue(propValue[breakpoint], breakpoint);
          } else {
            const cssKey = breakpoint;
            acc[cssKey] = propValue[cssKey];
          }
          return acc;
        }, {});
      }
      const output = styleFromPropValue(propValue);
      return output;
    }
    function createEmptyBreakpointObject(breakpointsInput = {}) {
      var _breakpointsInput$key;
      const breakpointsInOrder = (_breakpointsInput$key = breakpointsInput.keys) == null ? void 0 : _breakpointsInput$key.reduce((acc, key) => {
        const breakpointStyleKey = breakpointsInput.up(key);
        acc[breakpointStyleKey] = {};
        return acc;
      }, {});
      return breakpointsInOrder || {};
    }
    function removeUnusedBreakpoints(breakpointKeys, style) {
      return breakpointKeys.reduce((acc, key) => {
        const breakpointOutput = acc[key];
        const isBreakpointUnused = !breakpointOutput || Object.keys(breakpointOutput).length === 0;
        if (isBreakpointUnused) {
          delete acc[key];
        }
        return acc;
      }, style);
    }

    function getPath(obj, path, checkVars = true) {
      if (!path || typeof path !== 'string') {
        return null;
      }

      // Check if CSS variables are used
      if (obj && obj.vars && checkVars) {
        const val = `vars.${path}`.split('.').reduce((acc, item) => acc && acc[item] ? acc[item] : null, obj);
        if (val != null) {
          return val;
        }
      }
      return path.split('.').reduce((acc, item) => {
        if (acc && acc[item] != null) {
          return acc[item];
        }
        return null;
      }, obj);
    }
    function getStyleValue$1(themeMapping, transform, propValueFinal, userValue = propValueFinal) {
      let value;
      if (typeof themeMapping === 'function') {
        value = themeMapping(propValueFinal);
      } else if (Array.isArray(themeMapping)) {
        value = themeMapping[propValueFinal] || userValue;
      } else {
        value = getPath(themeMapping, propValueFinal) || userValue;
      }
      if (transform) {
        value = transform(value, userValue, themeMapping);
      }
      return value;
    }
    function style$1(options) {
      const {
        prop,
        cssProperty = options.prop,
        themeKey,
        transform
      } = options;

      // false positive
      // eslint-disable-next-line react/function-component-definition
      const fn = props => {
        if (props[prop] == null) {
          return null;
        }
        const propValue = props[prop];
        const theme = props.theme;
        const themeMapping = getPath(theme, themeKey) || {};
        const styleFromPropValue = propValueFinal => {
          let value = getStyleValue$1(themeMapping, transform, propValueFinal);
          if (propValueFinal === value && typeof propValueFinal === 'string') {
            // Haven't found value
            value = getStyleValue$1(themeMapping, transform, `${prop}${propValueFinal === 'default' ? '' : capitalize(propValueFinal)}`, propValueFinal);
          }
          if (cssProperty === false) {
            return value;
          }
          return {
            [cssProperty]: value
          };
        };
        return handleBreakpoints(props, propValue, styleFromPropValue);
      };
      fn.propTypes = {};
      fn.filterProps = [prop];
      return fn;
    }

    function memoize(fn) {
      const cache = {};
      return arg => {
        if (cache[arg] === undefined) {
          cache[arg] = fn(arg);
        }
        return cache[arg];
      };
    }

    const properties = {
      m: 'margin',
      p: 'padding'
    };
    const directions = {
      t: 'Top',
      r: 'Right',
      b: 'Bottom',
      l: 'Left',
      x: ['Left', 'Right'],
      y: ['Top', 'Bottom']
    };
    const aliases = {
      marginX: 'mx',
      marginY: 'my',
      paddingX: 'px',
      paddingY: 'py'
    };

    // memoize() impact:
    // From 300,000 ops/sec
    // To 350,000 ops/sec
    const getCssProperties = memoize(prop => {
      // It's not a shorthand notation.
      if (prop.length > 2) {
        if (aliases[prop]) {
          prop = aliases[prop];
        } else {
          return [prop];
        }
      }
      const [a, b] = prop.split('');
      const property = properties[a];
      const direction = directions[b] || '';
      return Array.isArray(direction) ? direction.map(dir => property + dir) : [property + direction];
    });
    const marginKeys = ['m', 'mt', 'mr', 'mb', 'ml', 'mx', 'my', 'margin', 'marginTop', 'marginRight', 'marginBottom', 'marginLeft', 'marginX', 'marginY', 'marginInline', 'marginInlineStart', 'marginInlineEnd', 'marginBlock', 'marginBlockStart', 'marginBlockEnd'];
    const paddingKeys = ['p', 'pt', 'pr', 'pb', 'pl', 'px', 'py', 'padding', 'paddingTop', 'paddingRight', 'paddingBottom', 'paddingLeft', 'paddingX', 'paddingY', 'paddingInline', 'paddingInlineStart', 'paddingInlineEnd', 'paddingBlock', 'paddingBlockStart', 'paddingBlockEnd'];
    [...marginKeys, ...paddingKeys];
    function createUnaryUnit(theme, themeKey, defaultValue, propName) {
      var _getPath;
      const themeSpacing = (_getPath = getPath(theme, themeKey, false)) != null ? _getPath : defaultValue;
      if (typeof themeSpacing === 'number') {
        return abs => {
          if (typeof abs === 'string') {
            return abs;
          }
          return themeSpacing * abs;
        };
      }
      if (Array.isArray(themeSpacing)) {
        return abs => {
          if (typeof abs === 'string') {
            return abs;
          }
          return themeSpacing[abs];
        };
      }
      if (typeof themeSpacing === 'function') {
        return themeSpacing;
      }
      return () => undefined;
    }
    function createUnarySpacing(theme) {
      return createUnaryUnit(theme, 'spacing', 8);
    }
    function getValue(transformer, propValue) {
      if (typeof propValue === 'string' || propValue == null) {
        return propValue;
      }
      const abs = Math.abs(propValue);
      const transformed = transformer(abs);
      if (propValue >= 0) {
        return transformed;
      }
      if (typeof transformed === 'number') {
        return -transformed;
      }
      return `-${transformed}`;
    }
    function getStyleFromPropValue(cssProperties, transformer) {
      return propValue => cssProperties.reduce((acc, cssProperty) => {
        acc[cssProperty] = getValue(transformer, propValue);
        return acc;
      }, {});
    }
    function resolveCssProperty(props, keys, prop, transformer) {
      // Using a hash computation over an array iteration could be faster, but with only 28 items,
      // it's doesn't worth the bundle size.
      if (keys.indexOf(prop) === -1) {
        return null;
      }
      const cssProperties = getCssProperties(prop);
      const styleFromPropValue = getStyleFromPropValue(cssProperties, transformer);
      const propValue = props[prop];
      return handleBreakpoints(props, propValue, styleFromPropValue);
    }
    function style(props, keys) {
      const transformer = createUnarySpacing(props.theme);
      return Object.keys(props).map(prop => resolveCssProperty(props, keys, prop, transformer)).reduce(merge, {});
    }
    function margin(props) {
      return style(props, marginKeys);
    }
    margin.propTypes = {};
    margin.filterProps = marginKeys;
    function padding(props) {
      return style(props, paddingKeys);
    }
    padding.propTypes = {};
    padding.filterProps = paddingKeys;

    // The different signatures imply different meaning for their arguments that can't be expressed structurally.
    // We express the difference with variable names.
    /* tslint:disable:unified-signatures */
    /* tslint:enable:unified-signatures */

    function createSpacing(spacingInput = 8) {
      // Already transformed.
      if (spacingInput.mui) {
        return spacingInput;
      }

      // Material Design layouts are visually balanced. Most measurements align to an 8dp grid, which aligns both spacing and the overall layout.
      // Smaller components, such as icons, can align to a 4dp grid.
      // https://m2.material.io/design/layout/understanding-layout.html
      const transform = createUnarySpacing({
        spacing: spacingInput
      });
      const spacing = (...argsInput) => {
        const args = argsInput.length === 0 ? [1] : argsInput;
        return args.map(argument => {
          const output = transform(argument);
          return typeof output === 'number' ? `${output}px` : output;
        }).join(' ');
      };
      spacing.mui = true;
      return spacing;
    }

    function compose(...styles) {
      const handlers = styles.reduce((acc, style) => {
        style.filterProps.forEach(prop => {
          acc[prop] = style;
        });
        return acc;
      }, {});

      // false positive
      // eslint-disable-next-line react/function-component-definition
      const fn = props => {
        return Object.keys(props).reduce((acc, prop) => {
          if (handlers[prop]) {
            return merge(acc, handlers[prop](props));
          }
          return acc;
        }, {});
      };
      fn.propTypes = {};
      fn.filterProps = styles.reduce((acc, style) => acc.concat(style.filterProps), []);
      return fn;
    }

    function borderTransform(value) {
      if (typeof value !== 'number') {
        return value;
      }
      return `${value}px solid`;
    }
    const border = style$1({
      prop: 'border',
      themeKey: 'borders',
      transform: borderTransform
    });
    const borderTop = style$1({
      prop: 'borderTop',
      themeKey: 'borders',
      transform: borderTransform
    });
    const borderRight = style$1({
      prop: 'borderRight',
      themeKey: 'borders',
      transform: borderTransform
    });
    const borderBottom = style$1({
      prop: 'borderBottom',
      themeKey: 'borders',
      transform: borderTransform
    });
    const borderLeft = style$1({
      prop: 'borderLeft',
      themeKey: 'borders',
      transform: borderTransform
    });
    const borderColor = style$1({
      prop: 'borderColor',
      themeKey: 'palette'
    });
    const borderTopColor = style$1({
      prop: 'borderTopColor',
      themeKey: 'palette'
    });
    const borderRightColor = style$1({
      prop: 'borderRightColor',
      themeKey: 'palette'
    });
    const borderBottomColor = style$1({
      prop: 'borderBottomColor',
      themeKey: 'palette'
    });
    const borderLeftColor = style$1({
      prop: 'borderLeftColor',
      themeKey: 'palette'
    });

    // false positive
    // eslint-disable-next-line react/function-component-definition
    const borderRadius = props => {
      if (props.borderRadius !== undefined && props.borderRadius !== null) {
        const transformer = createUnaryUnit(props.theme, 'shape.borderRadius', 4);
        const styleFromPropValue = propValue => ({
          borderRadius: getValue(transformer, propValue)
        });
        return handleBreakpoints(props, props.borderRadius, styleFromPropValue);
      }
      return null;
    };
    borderRadius.propTypes = {};
    borderRadius.filterProps = ['borderRadius'];
    compose(border, borderTop, borderRight, borderBottom, borderLeft, borderColor, borderTopColor, borderRightColor, borderBottomColor, borderLeftColor, borderRadius);

    // false positive
    // eslint-disable-next-line react/function-component-definition
    const gap = props => {
      if (props.gap !== undefined && props.gap !== null) {
        const transformer = createUnaryUnit(props.theme, 'spacing', 8);
        const styleFromPropValue = propValue => ({
          gap: getValue(transformer, propValue)
        });
        return handleBreakpoints(props, props.gap, styleFromPropValue);
      }
      return null;
    };
    gap.propTypes = {};
    gap.filterProps = ['gap'];

    // false positive
    // eslint-disable-next-line react/function-component-definition
    const columnGap = props => {
      if (props.columnGap !== undefined && props.columnGap !== null) {
        const transformer = createUnaryUnit(props.theme, 'spacing', 8);
        const styleFromPropValue = propValue => ({
          columnGap: getValue(transformer, propValue)
        });
        return handleBreakpoints(props, props.columnGap, styleFromPropValue);
      }
      return null;
    };
    columnGap.propTypes = {};
    columnGap.filterProps = ['columnGap'];

    // false positive
    // eslint-disable-next-line react/function-component-definition
    const rowGap = props => {
      if (props.rowGap !== undefined && props.rowGap !== null) {
        const transformer = createUnaryUnit(props.theme, 'spacing', 8);
        const styleFromPropValue = propValue => ({
          rowGap: getValue(transformer, propValue)
        });
        return handleBreakpoints(props, props.rowGap, styleFromPropValue);
      }
      return null;
    };
    rowGap.propTypes = {};
    rowGap.filterProps = ['rowGap'];
    const gridColumn = style$1({
      prop: 'gridColumn'
    });
    const gridRow = style$1({
      prop: 'gridRow'
    });
    const gridAutoFlow = style$1({
      prop: 'gridAutoFlow'
    });
    const gridAutoColumns = style$1({
      prop: 'gridAutoColumns'
    });
    const gridAutoRows = style$1({
      prop: 'gridAutoRows'
    });
    const gridTemplateColumns = style$1({
      prop: 'gridTemplateColumns'
    });
    const gridTemplateRows = style$1({
      prop: 'gridTemplateRows'
    });
    const gridTemplateAreas = style$1({
      prop: 'gridTemplateAreas'
    });
    const gridArea = style$1({
      prop: 'gridArea'
    });
    compose(gap, columnGap, rowGap, gridColumn, gridRow, gridAutoFlow, gridAutoColumns, gridAutoRows, gridTemplateColumns, gridTemplateRows, gridTemplateAreas, gridArea);

    function paletteTransform(value, userValue) {
      if (userValue === 'grey') {
        return userValue;
      }
      return value;
    }
    const color = style$1({
      prop: 'color',
      themeKey: 'palette',
      transform: paletteTransform
    });
    const bgcolor = style$1({
      prop: 'bgcolor',
      cssProperty: 'backgroundColor',
      themeKey: 'palette',
      transform: paletteTransform
    });
    const backgroundColor = style$1({
      prop: 'backgroundColor',
      themeKey: 'palette',
      transform: paletteTransform
    });
    compose(color, bgcolor, backgroundColor);

    function sizingTransform(value) {
      return value <= 1 && value !== 0 ? `${value * 100}%` : value;
    }
    const width = style$1({
      prop: 'width',
      transform: sizingTransform
    });
    const maxWidth = props => {
      if (props.maxWidth !== undefined && props.maxWidth !== null) {
        const styleFromPropValue = propValue => {
          var _props$theme;
          const breakpoint = ((_props$theme = props.theme) == null || (_props$theme = _props$theme.breakpoints) == null || (_props$theme = _props$theme.values) == null ? void 0 : _props$theme[propValue]) || values[propValue];
          return {
            maxWidth: breakpoint || sizingTransform(propValue)
          };
        };
        return handleBreakpoints(props, props.maxWidth, styleFromPropValue);
      }
      return null;
    };
    maxWidth.filterProps = ['maxWidth'];
    const minWidth = style$1({
      prop: 'minWidth',
      transform: sizingTransform
    });
    const height = style$1({
      prop: 'height',
      transform: sizingTransform
    });
    const maxHeight = style$1({
      prop: 'maxHeight',
      transform: sizingTransform
    });
    const minHeight = style$1({
      prop: 'minHeight',
      transform: sizingTransform
    });
    style$1({
      prop: 'size',
      cssProperty: 'width',
      transform: sizingTransform
    });
    style$1({
      prop: 'size',
      cssProperty: 'height',
      transform: sizingTransform
    });
    const boxSizing = style$1({
      prop: 'boxSizing'
    });
    compose(width, maxWidth, minWidth, height, maxHeight, minHeight, boxSizing);

    const defaultSxConfig = {
      // borders
      border: {
        themeKey: 'borders',
        transform: borderTransform
      },
      borderTop: {
        themeKey: 'borders',
        transform: borderTransform
      },
      borderRight: {
        themeKey: 'borders',
        transform: borderTransform
      },
      borderBottom: {
        themeKey: 'borders',
        transform: borderTransform
      },
      borderLeft: {
        themeKey: 'borders',
        transform: borderTransform
      },
      borderColor: {
        themeKey: 'palette'
      },
      borderTopColor: {
        themeKey: 'palette'
      },
      borderRightColor: {
        themeKey: 'palette'
      },
      borderBottomColor: {
        themeKey: 'palette'
      },
      borderLeftColor: {
        themeKey: 'palette'
      },
      borderRadius: {
        themeKey: 'shape.borderRadius',
        style: borderRadius
      },
      // palette
      color: {
        themeKey: 'palette',
        transform: paletteTransform
      },
      bgcolor: {
        themeKey: 'palette',
        cssProperty: 'backgroundColor',
        transform: paletteTransform
      },
      backgroundColor: {
        themeKey: 'palette',
        transform: paletteTransform
      },
      // spacing
      p: {
        style: padding
      },
      pt: {
        style: padding
      },
      pr: {
        style: padding
      },
      pb: {
        style: padding
      },
      pl: {
        style: padding
      },
      px: {
        style: padding
      },
      py: {
        style: padding
      },
      padding: {
        style: padding
      },
      paddingTop: {
        style: padding
      },
      paddingRight: {
        style: padding
      },
      paddingBottom: {
        style: padding
      },
      paddingLeft: {
        style: padding
      },
      paddingX: {
        style: padding
      },
      paddingY: {
        style: padding
      },
      paddingInline: {
        style: padding
      },
      paddingInlineStart: {
        style: padding
      },
      paddingInlineEnd: {
        style: padding
      },
      paddingBlock: {
        style: padding
      },
      paddingBlockStart: {
        style: padding
      },
      paddingBlockEnd: {
        style: padding
      },
      m: {
        style: margin
      },
      mt: {
        style: margin
      },
      mr: {
        style: margin
      },
      mb: {
        style: margin
      },
      ml: {
        style: margin
      },
      mx: {
        style: margin
      },
      my: {
        style: margin
      },
      margin: {
        style: margin
      },
      marginTop: {
        style: margin
      },
      marginRight: {
        style: margin
      },
      marginBottom: {
        style: margin
      },
      marginLeft: {
        style: margin
      },
      marginX: {
        style: margin
      },
      marginY: {
        style: margin
      },
      marginInline: {
        style: margin
      },
      marginInlineStart: {
        style: margin
      },
      marginInlineEnd: {
        style: margin
      },
      marginBlock: {
        style: margin
      },
      marginBlockStart: {
        style: margin
      },
      marginBlockEnd: {
        style: margin
      },
      // display
      displayPrint: {
        cssProperty: false,
        transform: value => ({
          '@media print': {
            display: value
          }
        })
      },
      display: {},
      overflow: {},
      textOverflow: {},
      visibility: {},
      whiteSpace: {},
      // flexbox
      flexBasis: {},
      flexDirection: {},
      flexWrap: {},
      justifyContent: {},
      alignItems: {},
      alignContent: {},
      order: {},
      flex: {},
      flexGrow: {},
      flexShrink: {},
      alignSelf: {},
      justifyItems: {},
      justifySelf: {},
      // grid
      gap: {
        style: gap
      },
      rowGap: {
        style: rowGap
      },
      columnGap: {
        style: columnGap
      },
      gridColumn: {},
      gridRow: {},
      gridAutoFlow: {},
      gridAutoColumns: {},
      gridAutoRows: {},
      gridTemplateColumns: {},
      gridTemplateRows: {},
      gridTemplateAreas: {},
      gridArea: {},
      // positions
      position: {},
      zIndex: {
        themeKey: 'zIndex'
      },
      top: {},
      right: {},
      bottom: {},
      left: {},
      // shadows
      boxShadow: {
        themeKey: 'shadows'
      },
      // sizing
      width: {
        transform: sizingTransform
      },
      maxWidth: {
        style: maxWidth
      },
      minWidth: {
        transform: sizingTransform
      },
      height: {
        transform: sizingTransform
      },
      maxHeight: {
        transform: sizingTransform
      },
      minHeight: {
        transform: sizingTransform
      },
      boxSizing: {},
      // typography
      fontFamily: {
        themeKey: 'typography'
      },
      fontSize: {
        themeKey: 'typography'
      },
      fontStyle: {
        themeKey: 'typography'
      },
      fontWeight: {
        themeKey: 'typography'
      },
      letterSpacing: {},
      textTransform: {},
      lineHeight: {},
      textAlign: {},
      typography: {
        cssProperty: false,
        themeKey: 'typography'
      }
    };
    var defaultSxConfig$1 = defaultSxConfig;

    function objectsHaveSameKeys(...objects) {
      const allKeys = objects.reduce((keys, object) => keys.concat(Object.keys(object)), []);
      const union = new Set(allKeys);
      return objects.every(object => union.size === Object.keys(object).length);
    }
    function callIfFn(maybeFn, arg) {
      return typeof maybeFn === 'function' ? maybeFn(arg) : maybeFn;
    }

    // eslint-disable-next-line @typescript-eslint/naming-convention
    function unstable_createStyleFunctionSx() {
      function getThemeValue(prop, val, theme, config) {
        const props = {
          [prop]: val,
          theme
        };
        const options = config[prop];
        if (!options) {
          return {
            [prop]: val
          };
        }
        const {
          cssProperty = prop,
          themeKey,
          transform,
          style
        } = options;
        if (val == null) {
          return null;
        }
        if (themeKey === 'typography' && val === 'inherit') {
          return {
            [prop]: val
          };
        }
        const themeMapping = getPath(theme, themeKey) || {};
        if (style) {
          return style(props);
        }
        const styleFromPropValue = propValueFinal => {
          let value = getStyleValue$1(themeMapping, transform, propValueFinal);
          if (propValueFinal === value && typeof propValueFinal === 'string') {
            // Haven't found value
            value = getStyleValue$1(themeMapping, transform, `${prop}${propValueFinal === 'default' ? '' : capitalize(propValueFinal)}`, propValueFinal);
          }
          if (cssProperty === false) {
            return value;
          }
          return {
            [cssProperty]: value
          };
        };
        return handleBreakpoints(props, val, styleFromPropValue);
      }
      function styleFunctionSx(props) {
        var _theme$unstable_sxCon;
        const {
          sx,
          theme = {}
        } = props || {};
        if (!sx) {
          return null; // Emotion & styled-components will neglect null
        }

        const config = (_theme$unstable_sxCon = theme.unstable_sxConfig) != null ? _theme$unstable_sxCon : defaultSxConfig$1;

        /*
         * Receive `sxInput` as object or callback
         * and then recursively check keys & values to create media query object styles.
         * (the result will be used in `styled`)
         */
        function traverse(sxInput) {
          let sxObject = sxInput;
          if (typeof sxInput === 'function') {
            sxObject = sxInput(theme);
          } else if (typeof sxInput !== 'object') {
            // value
            return sxInput;
          }
          if (!sxObject) {
            return null;
          }
          const emptyBreakpoints = createEmptyBreakpointObject(theme.breakpoints);
          const breakpointsKeys = Object.keys(emptyBreakpoints);
          let css = emptyBreakpoints;
          Object.keys(sxObject).forEach(styleKey => {
            const value = callIfFn(sxObject[styleKey], theme);
            if (value !== null && value !== undefined) {
              if (typeof value === 'object') {
                if (config[styleKey]) {
                  css = merge(css, getThemeValue(styleKey, value, theme, config));
                } else {
                  const breakpointsValues = handleBreakpoints({
                    theme
                  }, value, x => ({
                    [styleKey]: x
                  }));
                  if (objectsHaveSameKeys(breakpointsValues, value)) {
                    css[styleKey] = styleFunctionSx({
                      sx: value,
                      theme
                    });
                  } else {
                    css = merge(css, breakpointsValues);
                  }
                }
              } else {
                css = merge(css, getThemeValue(styleKey, value, theme, config));
              }
            }
          });
          return removeUnusedBreakpoints(breakpointsKeys, css);
        }
        return Array.isArray(sx) ? sx.map(traverse) : traverse(sx);
      }
      return styleFunctionSx;
    }
    const styleFunctionSx = unstable_createStyleFunctionSx();
    styleFunctionSx.filterProps = ['sx'];
    var styleFunctionSx$1 = styleFunctionSx;

    const _excluded$g = ["breakpoints", "palette", "spacing", "shape"];
    function createTheme$1(options = {}, ...args) {
      const {
          breakpoints: breakpointsInput = {},
          palette: paletteInput = {},
          spacing: spacingInput,
          shape: shapeInput = {}
        } = options,
        other = _objectWithoutPropertiesLoose$1(options, _excluded$g);
      const breakpoints = createBreakpoints(breakpointsInput);
      const spacing = createSpacing(spacingInput);
      let muiTheme = deepmerge({
        breakpoints,
        direction: 'ltr',
        components: {},
        // Inject component definitions.
        palette: _extends$2({
          mode: 'light'
        }, paletteInput),
        spacing,
        shape: _extends$2({}, shape, shapeInput)
      }, other);
      muiTheme = args.reduce((acc, argument) => deepmerge(acc, argument), muiTheme);
      muiTheme.unstable_sxConfig = _extends$2({}, defaultSxConfig$1, other == null ? void 0 : other.unstable_sxConfig);
      muiTheme.unstable_sx = function sx(props) {
        return styleFunctionSx$1({
          sx: props,
          theme: this
        });
      };
      return muiTheme;
    }

    function isObjectEmpty(obj) {
      return Object.keys(obj).length === 0;
    }
    function useTheme$2(defaultTheme = null) {
      const contextTheme = reactExports.useContext(ThemeContext$2);
      return !contextTheme || isObjectEmpty(contextTheme) ? defaultTheme : contextTheme;
    }

    const systemDefaultTheme$1 = createTheme$1();
    function useTheme$1(defaultTheme = systemDefaultTheme$1) {
      return useTheme$2(defaultTheme);
    }

    function GlobalStyles$1({
      styles,
      themeId,
      defaultTheme = {}
    }) {
      const upperTheme = useTheme$1(defaultTheme);
      const globalStyles = typeof styles === 'function' ? styles(themeId ? upperTheme[themeId] || upperTheme : upperTheme) : styles;
      return /*#__PURE__*/jsxRuntimeExports.jsx(GlobalStyles$2, {
        styles: globalStyles
      });
    }

    const _excluded$f = ["sx"];
    const splitProps = props => {
      var _props$theme$unstable, _props$theme;
      const result = {
        systemProps: {},
        otherProps: {}
      };
      const config = (_props$theme$unstable = props == null || (_props$theme = props.theme) == null ? void 0 : _props$theme.unstable_sxConfig) != null ? _props$theme$unstable : defaultSxConfig$1;
      Object.keys(props).forEach(prop => {
        if (config[prop]) {
          result.systemProps[prop] = props[prop];
        } else {
          result.otherProps[prop] = props[prop];
        }
      });
      return result;
    };
    function extendSxProp(props) {
      const {
          sx: inSx
        } = props,
        other = _objectWithoutPropertiesLoose$1(props, _excluded$f);
      const {
        systemProps,
        otherProps
      } = splitProps(other);
      let finalSx;
      if (Array.isArray(inSx)) {
        finalSx = [systemProps, ...inSx];
      } else if (typeof inSx === 'function') {
        finalSx = (...args) => {
          const result = inSx(...args);
          if (!isPlainObject$1(result)) {
            return systemProps;
          }
          return _extends$2({}, systemProps, result);
        };
      } else {
        finalSx = _extends$2({}, systemProps, inSx);
      }
      return _extends$2({}, otherProps, {
        sx: finalSx
      });
    }

    function r$4(e){var t,f,n="";if("string"==typeof e||"number"==typeof e)n+=e;else if("object"==typeof e)if(Array.isArray(e))for(t=0;t<e.length;t++)e[t]&&(f=r$4(e[t]))&&(n&&(n+=" "),n+=f);else for(t in e)e[t]&&(n&&(n+=" "),n+=t);return n}function clsx$2(){for(var e,t,f=0,n="";f<arguments.length;)(e=arguments[f++])&&(t=r$4(e))&&(n&&(n+=" "),n+=t);return n}

    const _excluded$e = ["className", "component"];
    function createBox(options = {}) {
      const {
        themeId,
        defaultTheme,
        defaultClassName = 'MuiBox-root',
        generateClassName
      } = options;
      const BoxRoot = styled$1('div', {
        shouldForwardProp: prop => prop !== 'theme' && prop !== 'sx' && prop !== 'as'
      })(styleFunctionSx$1);
      const Box = /*#__PURE__*/reactExports.forwardRef(function Box(inProps, ref) {
        const theme = useTheme$1(defaultTheme);
        const _extendSxProp = extendSxProp(inProps),
          {
            className,
            component = 'div'
          } = _extendSxProp,
          other = _objectWithoutPropertiesLoose$1(_extendSxProp, _excluded$e);
        return /*#__PURE__*/jsxRuntimeExports.jsx(BoxRoot, _extends$2({
          as: component,
          ref: ref,
          className: clsx$2(className, generateClassName ? generateClassName(defaultClassName) : defaultClassName),
          theme: themeId ? theme[themeId] || theme : theme
        }, other));
      });
      return Box;
    }

    const _excluded$d = ["variant"];
    function isEmpty$2(string) {
      return string.length === 0;
    }

    /**
     * Generates string classKey based on the properties provided. It starts with the
     * variant if defined, and then it appends all other properties in alphabetical order.
     * @param {object} props - the properties for which the classKey should be created.
     */
    function propsToClassKey(props) {
      const {
          variant
        } = props,
        other = _objectWithoutPropertiesLoose$1(props, _excluded$d);
      let classKey = variant || '';
      Object.keys(other).sort().forEach(key => {
        if (key === 'color') {
          classKey += isEmpty$2(classKey) ? props[key] : capitalize(props[key]);
        } else {
          classKey += `${isEmpty$2(classKey) ? key : capitalize(key)}${capitalize(props[key].toString())}`;
        }
      });
      return classKey;
    }

    const _excluded$c = ["name", "slot", "skipVariantsResolver", "skipSx", "overridesResolver"];
    function isEmpty$1(obj) {
      return Object.keys(obj).length === 0;
    }

    // https://github.com/emotion-js/emotion/blob/26ded6109fcd8ca9875cc2ce4564fee678a3f3c5/packages/styled/src/utils.js#L40
    function isStringTag(tag) {
      return typeof tag === 'string' &&
      // 96 is one less than the char code
      // for "a" so this is checking that
      // it's a lowercase character
      tag.charCodeAt(0) > 96;
    }
    const getStyleOverrides = (name, theme) => {
      if (theme.components && theme.components[name] && theme.components[name].styleOverrides) {
        return theme.components[name].styleOverrides;
      }
      return null;
    };
    const getVariantStyles = (name, theme) => {
      let variants = [];
      if (theme && theme.components && theme.components[name] && theme.components[name].variants) {
        variants = theme.components[name].variants;
      }
      const variantsStyles = {};
      variants.forEach(definition => {
        const key = propsToClassKey(definition.props);
        variantsStyles[key] = definition.style;
      });
      return variantsStyles;
    };
    const variantsResolver = (props, styles, theme, name) => {
      var _theme$components;
      const {
        ownerState = {}
      } = props;
      const variantsStyles = [];
      const themeVariants = theme == null || (_theme$components = theme.components) == null || (_theme$components = _theme$components[name]) == null ? void 0 : _theme$components.variants;
      if (themeVariants) {
        themeVariants.forEach(themeVariant => {
          let isMatch = true;
          Object.keys(themeVariant.props).forEach(key => {
            if (ownerState[key] !== themeVariant.props[key] && props[key] !== themeVariant.props[key]) {
              isMatch = false;
            }
          });
          if (isMatch) {
            variantsStyles.push(styles[propsToClassKey(themeVariant.props)]);
          }
        });
      }
      return variantsStyles;
    };

    // Update /system/styled/#api in case if this changes
    function shouldForwardProp(prop) {
      return prop !== 'ownerState' && prop !== 'theme' && prop !== 'sx' && prop !== 'as';
    }
    const systemDefaultTheme = createTheme$1();
    function resolveTheme({
      defaultTheme,
      theme,
      themeId
    }) {
      return isEmpty$1(theme) ? defaultTheme : theme[themeId] || theme;
    }
    function createStyled(input = {}) {
      const {
        themeId,
        defaultTheme = systemDefaultTheme,
        rootShouldForwardProp = shouldForwardProp,
        slotShouldForwardProp = shouldForwardProp
      } = input;
      const systemSx = props => {
        return styleFunctionSx$1(_extends$2({}, props, {
          theme: resolveTheme(_extends$2({}, props, {
            defaultTheme,
            themeId
          }))
        }));
      };
      systemSx.__mui_systemSx = true;
      return (tag, inputOptions = {}) => {
        // Filter out the `sx` style function from the previous styled component to prevent unnecessary styles generated by the composite components.
        internal_processStyles(tag, styles => styles.filter(style => !(style != null && style.__mui_systemSx)));
        const {
            name: componentName,
            slot: componentSlot,
            skipVariantsResolver: inputSkipVariantsResolver,
            skipSx: inputSkipSx,
            overridesResolver
          } = inputOptions,
          options = _objectWithoutPropertiesLoose$1(inputOptions, _excluded$c);

        // if skipVariantsResolver option is defined, take the value, otherwise, true for root and false for other slots.
        const skipVariantsResolver = inputSkipVariantsResolver !== undefined ? inputSkipVariantsResolver : componentSlot && componentSlot !== 'Root' || false;
        const skipSx = inputSkipSx || false;
        let label;
        let shouldForwardPropOption = shouldForwardProp;
        if (componentSlot === 'Root') {
          shouldForwardPropOption = rootShouldForwardProp;
        } else if (componentSlot) {
          // any other slot specified
          shouldForwardPropOption = slotShouldForwardProp;
        } else if (isStringTag(tag)) {
          // for string (html) tag, preserve the behavior in emotion & styled-components.
          shouldForwardPropOption = undefined;
        }
        const defaultStyledResolver = styled$1(tag, _extends$2({
          shouldForwardProp: shouldForwardPropOption,
          label
        }, options));
        const muiStyledResolver = (styleArg, ...expressions) => {
          const expressionsWithDefaultTheme = expressions ? expressions.map(stylesArg => {
            // On the server Emotion doesn't use React.forwardRef for creating components, so the created
            // component stays as a function. This condition makes sure that we do not interpolate functions
            // which are basically components used as a selectors.
            return typeof stylesArg === 'function' && stylesArg.__emotion_real !== stylesArg ? props => {
              return stylesArg(_extends$2({}, props, {
                theme: resolveTheme(_extends$2({}, props, {
                  defaultTheme,
                  themeId
                }))
              }));
            } : stylesArg;
          }) : [];
          let transformedStyleArg = styleArg;
          if (componentName && overridesResolver) {
            expressionsWithDefaultTheme.push(props => {
              const theme = resolveTheme(_extends$2({}, props, {
                defaultTheme,
                themeId
              }));
              const styleOverrides = getStyleOverrides(componentName, theme);
              if (styleOverrides) {
                const resolvedStyleOverrides = {};
                Object.entries(styleOverrides).forEach(([slotKey, slotStyle]) => {
                  resolvedStyleOverrides[slotKey] = typeof slotStyle === 'function' ? slotStyle(_extends$2({}, props, {
                    theme
                  })) : slotStyle;
                });
                return overridesResolver(props, resolvedStyleOverrides);
              }
              return null;
            });
          }
          if (componentName && !skipVariantsResolver) {
            expressionsWithDefaultTheme.push(props => {
              const theme = resolveTheme(_extends$2({}, props, {
                defaultTheme,
                themeId
              }));
              return variantsResolver(props, getVariantStyles(componentName, theme), theme, componentName);
            });
          }
          if (!skipSx) {
            expressionsWithDefaultTheme.push(systemSx);
          }
          const numOfCustomFnsApplied = expressionsWithDefaultTheme.length - expressions.length;
          if (Array.isArray(styleArg) && numOfCustomFnsApplied > 0) {
            const placeholders = new Array(numOfCustomFnsApplied).fill('');
            // If the type is array, than we need to add placeholders in the template for the overrides, variants and the sx styles.
            transformedStyleArg = [...styleArg, ...placeholders];
            transformedStyleArg.raw = [...styleArg.raw, ...placeholders];
          } else if (typeof styleArg === 'function' &&
          // On the server Emotion doesn't use React.forwardRef for creating components, so the created
          // component stays as a function. This condition makes sure that we do not interpolate functions
          // which are basically components used as a selectors.
          styleArg.__emotion_real !== styleArg) {
            // If the type is function, we need to define the default theme.
            transformedStyleArg = props => styleArg(_extends$2({}, props, {
              theme: resolveTheme(_extends$2({}, props, {
                defaultTheme,
                themeId
              }))
            }));
          }
          const Component = defaultStyledResolver(transformedStyleArg, ...expressionsWithDefaultTheme);
          if (tag.muiName) {
            Component.muiName = tag.muiName;
          }
          return Component;
        };
        if (defaultStyledResolver.withConfig) {
          muiStyledResolver.withConfig = defaultStyledResolver.withConfig;
        }
        return muiStyledResolver;
      };
    }

    function getThemeProps(params) {
      const {
        theme,
        name,
        props
      } = params;
      if (!theme || !theme.components || !theme.components[name] || !theme.components[name].defaultProps) {
        return props;
      }
      return resolveProps(theme.components[name].defaultProps, props);
    }

    function useThemeProps$1({
      props,
      name,
      defaultTheme,
      themeId
    }) {
      let theme = useTheme$1(defaultTheme);
      if (themeId) {
        theme = theme[themeId] || theme;
      }
      const mergedProps = getThemeProps({
        theme,
        name,
        props
      });
      return mergedProps;
    }

    /* eslint-disable @typescript-eslint/naming-convention */
    /**
     * Returns a number whose value is limited to the given range.
     * @param {number} value The value to be clamped
     * @param {number} min The lower boundary of the output range
     * @param {number} max The upper boundary of the output range
     * @returns {number} A number in the range [min, max]
     */
    function clamp(value, min = 0, max = 1) {
      return Math.min(Math.max(min, value), max);
    }

    /**
     * Converts a color from CSS hex format to CSS rgb format.
     * @param {string} color - Hex color, i.e. #nnn or #nnnnnn
     * @returns {string} A CSS rgb color string
     */
    function hexToRgb(color) {
      color = color.slice(1);
      const re = new RegExp(`.{1,${color.length >= 6 ? 2 : 1}}`, 'g');
      let colors = color.match(re);
      if (colors && colors[0].length === 1) {
        colors = colors.map(n => n + n);
      }
      return colors ? `rgb${colors.length === 4 ? 'a' : ''}(${colors.map((n, index) => {
    return index < 3 ? parseInt(n, 16) : Math.round(parseInt(n, 16) / 255 * 1000) / 1000;
  }).join(', ')})` : '';
    }

    /**
     * Returns an object with the type and values of a color.
     *
     * Note: Does not support rgb % values.
     * @param {string} color - CSS color, i.e. one of: #nnn, #nnnnnn, rgb(), rgba(), hsl(), hsla(), color()
     * @returns {object} - A MUI color object: {type: string, values: number[]}
     */
    function decomposeColor(color) {
      // Idempotent
      if (color.type) {
        return color;
      }
      if (color.charAt(0) === '#') {
        return decomposeColor(hexToRgb(color));
      }
      const marker = color.indexOf('(');
      const type = color.substring(0, marker);
      if (['rgb', 'rgba', 'hsl', 'hsla', 'color'].indexOf(type) === -1) {
        throw new Error(formatMuiErrorMessage(9, color));
      }
      let values = color.substring(marker + 1, color.length - 1);
      let colorSpace;
      if (type === 'color') {
        values = values.split(' ');
        colorSpace = values.shift();
        if (values.length === 4 && values[3].charAt(0) === '/') {
          values[3] = values[3].slice(1);
        }
        if (['srgb', 'display-p3', 'a98-rgb', 'prophoto-rgb', 'rec-2020'].indexOf(colorSpace) === -1) {
          throw new Error(formatMuiErrorMessage(10, colorSpace));
        }
      } else {
        values = values.split(',');
      }
      values = values.map(value => parseFloat(value));
      return {
        type,
        values,
        colorSpace
      };
    }

    /**
     * Returns a channel created from the input color.
     *
     * @param {string} color - CSS color, i.e. one of: #nnn, #nnnnnn, rgb(), rgba(), hsl(), hsla(), color()
     * @returns {string} - The channel for the color, that can be used in rgba or hsla colors
     */
    const colorChannel = color => {
      const decomposedColor = decomposeColor(color);
      return decomposedColor.values.slice(0, 3).map((val, idx) => decomposedColor.type.indexOf('hsl') !== -1 && idx !== 0 ? `${val}%` : val).join(' ');
    };
    const private_safeColorChannel = (color, warning) => {
      try {
        return colorChannel(color);
      } catch (error) {
        if (warning && "production" !== 'production') {
          console.warn(warning);
        }
        return color;
      }
    };

    /**
     * Converts a color object with type and values to a string.
     * @param {object} color - Decomposed color
     * @param {string} color.type - One of: 'rgb', 'rgba', 'hsl', 'hsla', 'color'
     * @param {array} color.values - [n,n,n] or [n,n,n,n]
     * @returns {string} A CSS color string
     */
    function recomposeColor(color) {
      const {
        type,
        colorSpace
      } = color;
      let {
        values
      } = color;
      if (type.indexOf('rgb') !== -1) {
        // Only convert the first 3 values to int (i.e. not alpha)
        values = values.map((n, i) => i < 3 ? parseInt(n, 10) : n);
      } else if (type.indexOf('hsl') !== -1) {
        values[1] = `${values[1]}%`;
        values[2] = `${values[2]}%`;
      }
      if (type.indexOf('color') !== -1) {
        values = `${colorSpace} ${values.join(' ')}`;
      } else {
        values = `${values.join(', ')}`;
      }
      return `${type}(${values})`;
    }

    /**
     * Converts a color from hsl format to rgb format.
     * @param {string} color - HSL color values
     * @returns {string} rgb color values
     */
    function hslToRgb(color) {
      color = decomposeColor(color);
      const {
        values
      } = color;
      const h = values[0];
      const s = values[1] / 100;
      const l = values[2] / 100;
      const a = s * Math.min(l, 1 - l);
      const f = (n, k = (n + h / 30) % 12) => l - a * Math.max(Math.min(k - 3, 9 - k, 1), -1);
      let type = 'rgb';
      const rgb = [Math.round(f(0) * 255), Math.round(f(8) * 255), Math.round(f(4) * 255)];
      if (color.type === 'hsla') {
        type += 'a';
        rgb.push(values[3]);
      }
      return recomposeColor({
        type,
        values: rgb
      });
    }
    /**
     * The relative brightness of any point in a color space,
     * normalized to 0 for darkest black and 1 for lightest white.
     *
     * Formula: https://www.w3.org/TR/WCAG20-TECHS/G17.html#G17-tests
     * @param {string} color - CSS color, i.e. one of: #nnn, #nnnnnn, rgb(), rgba(), hsl(), hsla(), color()
     * @returns {number} The relative brightness of the color in the range 0 - 1
     */
    function getLuminance(color) {
      color = decomposeColor(color);
      let rgb = color.type === 'hsl' || color.type === 'hsla' ? decomposeColor(hslToRgb(color)).values : color.values;
      rgb = rgb.map(val => {
        if (color.type !== 'color') {
          val /= 255; // normalized
        }

        return val <= 0.03928 ? val / 12.92 : ((val + 0.055) / 1.055) ** 2.4;
      });

      // Truncate at 3 digits
      return Number((0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2]).toFixed(3));
    }

    /**
     * Calculates the contrast ratio between two colors.
     *
     * Formula: https://www.w3.org/TR/WCAG20-TECHS/G17.html#G17-tests
     * @param {string} foreground - CSS color, i.e. one of: #nnn, #nnnnnn, rgb(), rgba(), hsl(), hsla()
     * @param {string} background - CSS color, i.e. one of: #nnn, #nnnnnn, rgb(), rgba(), hsl(), hsla()
     * @returns {number} A contrast ratio value in the range 0 - 21.
     */
    function getContrastRatio(foreground, background) {
      const lumA = getLuminance(foreground);
      const lumB = getLuminance(background);
      return (Math.max(lumA, lumB) + 0.05) / (Math.min(lumA, lumB) + 0.05);
    }

    /**
     * Sets the absolute transparency of a color.
     * Any existing alpha values are overwritten.
     * @param {string} color - CSS color, i.e. one of: #nnn, #nnnnnn, rgb(), rgba(), hsl(), hsla(), color()
     * @param {number} value - value to set the alpha channel to in the range 0 - 1
     * @returns {string} A CSS color string. Hex input values are returned as rgb
     */
    function alpha(color, value) {
      color = decomposeColor(color);
      value = clamp(value);
      if (color.type === 'rgb' || color.type === 'hsl') {
        color.type += 'a';
      }
      if (color.type === 'color') {
        color.values[3] = `/${value}`;
      } else {
        color.values[3] = value;
      }
      return recomposeColor(color);
    }
    function private_safeAlpha(color, value, warning) {
      try {
        return alpha(color, value);
      } catch (error) {
        if (warning && "production" !== 'production') {
          console.warn(warning);
        }
        return color;
      }
    }

    /**
     * Darkens a color.
     * @param {string} color - CSS color, i.e. one of: #nnn, #nnnnnn, rgb(), rgba(), hsl(), hsla(), color()
     * @param {number} coefficient - multiplier in the range 0 - 1
     * @returns {string} A CSS color string. Hex input values are returned as rgb
     */
    function darken(color, coefficient) {
      color = decomposeColor(color);
      coefficient = clamp(coefficient);
      if (color.type.indexOf('hsl') !== -1) {
        color.values[2] *= 1 - coefficient;
      } else if (color.type.indexOf('rgb') !== -1 || color.type.indexOf('color') !== -1) {
        for (let i = 0; i < 3; i += 1) {
          color.values[i] *= 1 - coefficient;
        }
      }
      return recomposeColor(color);
    }
    function private_safeDarken(color, coefficient, warning) {
      try {
        return darken(color, coefficient);
      } catch (error) {
        if (warning && "production" !== 'production') {
          console.warn(warning);
        }
        return color;
      }
    }

    /**
     * Lightens a color.
     * @param {string} color - CSS color, i.e. one of: #nnn, #nnnnnn, rgb(), rgba(), hsl(), hsla(), color()
     * @param {number} coefficient - multiplier in the range 0 - 1
     * @returns {string} A CSS color string. Hex input values are returned as rgb
     */
    function lighten(color, coefficient) {
      color = decomposeColor(color);
      coefficient = clamp(coefficient);
      if (color.type.indexOf('hsl') !== -1) {
        color.values[2] += (100 - color.values[2]) * coefficient;
      } else if (color.type.indexOf('rgb') !== -1) {
        for (let i = 0; i < 3; i += 1) {
          color.values[i] += (255 - color.values[i]) * coefficient;
        }
      } else if (color.type.indexOf('color') !== -1) {
        for (let i = 0; i < 3; i += 1) {
          color.values[i] += (1 - color.values[i]) * coefficient;
        }
      }
      return recomposeColor(color);
    }
    function private_safeLighten(color, coefficient, warning) {
      try {
        return lighten(color, coefficient);
      } catch (error) {
        if (warning && "production" !== 'production') {
          console.warn(warning);
        }
        return color;
      }
    }
    function private_safeEmphasize(color, coefficient, warning) {
      try {
        return private_safeEmphasize(color, coefficient);
      } catch (error) {
        if (warning && "production" !== 'production') {
          console.warn(warning);
        }
        return color;
      }
    }

    function _extends$1() {
      _extends$1 = Object.assign ? Object.assign.bind() : function (target) {
        for (var i = 1; i < arguments.length; i++) {
          var source = arguments[i];
          for (var key in source) {
            if (Object.prototype.hasOwnProperty.call(source, key)) {
              target[key] = source[key];
            }
          }
        }
        return target;
      };
      return _extends$1.apply(this, arguments);
    }

    const ThemeContext = /*#__PURE__*/reactExports.createContext(null);
    var ThemeContext$1 = ThemeContext;

    function useTheme() {
      const theme = reactExports.useContext(ThemeContext$1);
      return theme;
    }

    const hasSymbol = typeof Symbol === 'function' && Symbol.for;
    var nested = hasSymbol ? Symbol.for('mui.nested') : '__THEME_NESTED__';

    function mergeOuterLocalTheme(outerTheme, localTheme) {
      if (typeof localTheme === 'function') {
        const mergedTheme = localTheme(outerTheme);
        return mergedTheme;
      }
      return _extends$1({}, outerTheme, localTheme);
    }

    /**
     * This component takes a `theme` prop.
     * It makes the `theme` available down the React tree thanks to React context.
     * This component should preferably be used at **the root of your component tree**.
     */
    function ThemeProvider$2(props) {
      const {
        children,
        theme: localTheme
      } = props;
      const outerTheme = useTheme();
      const theme = reactExports.useMemo(() => {
        const output = outerTheme === null ? localTheme : mergeOuterLocalTheme(outerTheme, localTheme);
        if (output != null) {
          output[nested] = outerTheme !== null;
        }
        return output;
      }, [localTheme, outerTheme]);
      return /*#__PURE__*/jsxRuntimeExports.jsx(ThemeContext$1.Provider, {
        value: theme,
        children: children
      });
    }

    const EMPTY_THEME = {};
    function useThemeScoping(themeId, upperTheme, localTheme, isPrivate = false) {
      return reactExports.useMemo(() => {
        const resolvedTheme = themeId ? upperTheme[themeId] || upperTheme : upperTheme;
        if (typeof localTheme === 'function') {
          const mergedTheme = localTheme(resolvedTheme);
          const result = themeId ? _extends$2({}, upperTheme, {
            [themeId]: mergedTheme
          }) : mergedTheme;
          // must return a function for the private theme to NOT merge with the upper theme.
          // see the test case "use provided theme from a callback" in ThemeProvider.test.js
          if (isPrivate) {
            return () => result;
          }
          return result;
        }
        return themeId ? _extends$2({}, upperTheme, {
          [themeId]: localTheme
        }) : _extends$2({}, upperTheme, localTheme);
      }, [themeId, upperTheme, localTheme, isPrivate]);
    }

    /**
     * This component makes the `theme` available down the React tree.
     * It should preferably be used at **the root of your component tree**.
     *
     * <ThemeProvider theme={theme}> // existing use case
     * <ThemeProvider theme={{ id: theme }}> // theme scoping
     */
    function ThemeProvider$1(props) {
      const {
        children,
        theme: localTheme,
        themeId
      } = props;
      const upperTheme = useTheme$2(EMPTY_THEME);
      const upperPrivateTheme = useTheme() || EMPTY_THEME;
      const engineTheme = useThemeScoping(themeId, upperTheme, localTheme);
      const privateTheme = useThemeScoping(themeId, upperPrivateTheme, localTheme, true);
      return /*#__PURE__*/jsxRuntimeExports.jsx(ThemeProvider$2, {
        theme: privateTheme,
        children: /*#__PURE__*/jsxRuntimeExports.jsx(ThemeContext$2.Provider, {
          value: engineTheme,
          children: children
        })
      });
    }

    const DEFAULT_MODE_STORAGE_KEY = 'mode';
    const DEFAULT_COLOR_SCHEME_STORAGE_KEY = 'color-scheme';
    const DEFAULT_ATTRIBUTE = 'data-color-scheme';
    function getInitColorSchemeScript(options) {
      const {
        defaultMode = 'light',
        defaultLightColorScheme = 'light',
        defaultDarkColorScheme = 'dark',
        modeStorageKey = DEFAULT_MODE_STORAGE_KEY,
        colorSchemeStorageKey = DEFAULT_COLOR_SCHEME_STORAGE_KEY,
        attribute = DEFAULT_ATTRIBUTE,
        colorSchemeNode = 'document.documentElement'
      } = options || {};
      return /*#__PURE__*/jsxRuntimeExports.jsx("script", {
        // eslint-disable-next-line react/no-danger
        dangerouslySetInnerHTML: {
          __html: `(function() { try {
        var mode = localStorage.getItem('${modeStorageKey}') || '${defaultMode}';
        var cssColorScheme = mode;
        var colorScheme = '';
        if (mode === 'system') {
          // handle system mode
          var mql = window.matchMedia('(prefers-color-scheme: dark)');
          if (mql.matches) {
            cssColorScheme = 'dark';
            colorScheme = localStorage.getItem('${colorSchemeStorageKey}-dark') || '${defaultDarkColorScheme}';
          } else {
            cssColorScheme = 'light';
            colorScheme = localStorage.getItem('${colorSchemeStorageKey}-light') || '${defaultLightColorScheme}';
          }
        }
        if (mode === 'light') {
          colorScheme = localStorage.getItem('${colorSchemeStorageKey}-light') || '${defaultLightColorScheme}';
        }
        if (mode === 'dark') {
          colorScheme = localStorage.getItem('${colorSchemeStorageKey}-dark') || '${defaultDarkColorScheme}';
        }
        if (colorScheme) {
          ${colorSchemeNode}.setAttribute('${attribute}', colorScheme);
        }
      } catch (e) {} })();`
        }
      }, "mui-color-scheme-init");
    }

    function getSystemMode(mode) {
      if (mode === 'system') {
        const mql = window.matchMedia('(prefers-color-scheme: dark)');
        if (mql.matches) {
          return 'dark';
        }
        return 'light';
      }
      return undefined;
    }
    function processState(state, callback) {
      if (state.mode === 'light' || state.mode === 'system' && state.systemMode === 'light') {
        return callback('light');
      }
      if (state.mode === 'dark' || state.mode === 'system' && state.systemMode === 'dark') {
        return callback('dark');
      }
      return undefined;
    }
    function getColorScheme(state) {
      return processState(state, mode => {
        if (mode === 'light') {
          return state.lightColorScheme;
        }
        if (mode === 'dark') {
          return state.darkColorScheme;
        }
        return undefined;
      });
    }
    function initializeValue(key, defaultValue) {
      let value;
      try {
        value = localStorage.getItem(key) || undefined;
        if (!value) {
          // the first time that user enters the site.
          localStorage.setItem(key, defaultValue);
        }
      } catch (e) {
        // Unsupported
      }
      return value || defaultValue;
    }
    function useCurrentColorScheme(options) {
      const {
        defaultMode = 'light',
        defaultLightColorScheme,
        defaultDarkColorScheme,
        supportedColorSchemes = [],
        modeStorageKey = DEFAULT_MODE_STORAGE_KEY,
        colorSchemeStorageKey = DEFAULT_COLOR_SCHEME_STORAGE_KEY,
        storageWindow = window
      } = options;
      const joinedColorSchemes = supportedColorSchemes.join(',');
      const [state, setState] = reactExports.useState(() => {
        const initialMode = initializeValue(modeStorageKey, defaultMode);
        const lightColorScheme = initializeValue(`${colorSchemeStorageKey}-light`, defaultLightColorScheme);
        const darkColorScheme = initializeValue(`${colorSchemeStorageKey}-dark`, defaultDarkColorScheme);
        return {
          mode: initialMode,
          systemMode: getSystemMode(initialMode),
          lightColorScheme,
          darkColorScheme
        };
      });
      const colorScheme = getColorScheme(state);
      const setMode = reactExports.useCallback(mode => {
        setState(currentState => {
          if (mode === currentState.mode) {
            // do nothing if mode does not change
            return currentState;
          }
          const newMode = !mode ? defaultMode : mode;
          try {
            localStorage.setItem(modeStorageKey, newMode);
          } catch (e) {
            // Unsupported
          }
          return _extends$2({}, currentState, {
            mode: newMode,
            systemMode: getSystemMode(newMode)
          });
        });
      }, [modeStorageKey, defaultMode]);
      const setColorScheme = reactExports.useCallback(value => {
        if (!value) {
          setState(currentState => {
            try {
              localStorage.setItem(`${colorSchemeStorageKey}-light`, defaultLightColorScheme);
              localStorage.setItem(`${colorSchemeStorageKey}-dark`, defaultDarkColorScheme);
            } catch (e) {
              // Unsupported
            }
            return _extends$2({}, currentState, {
              lightColorScheme: defaultLightColorScheme,
              darkColorScheme: defaultDarkColorScheme
            });
          });
        } else if (typeof value === 'string') {
          if (value && !joinedColorSchemes.includes(value)) {
            console.error(`\`${value}\` does not exist in \`theme.colorSchemes\`.`);
          } else {
            setState(currentState => {
              const newState = _extends$2({}, currentState);
              processState(currentState, mode => {
                try {
                  localStorage.setItem(`${colorSchemeStorageKey}-${mode}`, value);
                } catch (e) {
                  // Unsupported
                }
                if (mode === 'light') {
                  newState.lightColorScheme = value;
                }
                if (mode === 'dark') {
                  newState.darkColorScheme = value;
                }
              });
              return newState;
            });
          }
        } else {
          setState(currentState => {
            const newState = _extends$2({}, currentState);
            const newLightColorScheme = value.light === null ? defaultLightColorScheme : value.light;
            const newDarkColorScheme = value.dark === null ? defaultDarkColorScheme : value.dark;
            if (newLightColorScheme) {
              if (!joinedColorSchemes.includes(newLightColorScheme)) {
                console.error(`\`${newLightColorScheme}\` does not exist in \`theme.colorSchemes\`.`);
              } else {
                newState.lightColorScheme = newLightColorScheme;
                try {
                  localStorage.setItem(`${colorSchemeStorageKey}-light`, newLightColorScheme);
                } catch (error) {
                  // Unsupported
                }
              }
            }
            if (newDarkColorScheme) {
              if (!joinedColorSchemes.includes(newDarkColorScheme)) {
                console.error(`\`${newDarkColorScheme}\` does not exist in \`theme.colorSchemes\`.`);
              } else {
                newState.darkColorScheme = newDarkColorScheme;
                try {
                  localStorage.setItem(`${colorSchemeStorageKey}-dark`, newDarkColorScheme);
                } catch (error) {
                  // Unsupported
                }
              }
            }
            return newState;
          });
        }
      }, [joinedColorSchemes, colorSchemeStorageKey, defaultLightColorScheme, defaultDarkColorScheme]);
      const handleMediaQuery = reactExports.useCallback(e => {
        if (state.mode === 'system') {
          setState(currentState => _extends$2({}, currentState, {
            systemMode: e != null && e.matches ? 'dark' : 'light'
          }));
        }
      }, [state.mode]);

      // Ref hack to avoid adding handleMediaQuery as a dep
      const mediaListener = reactExports.useRef(handleMediaQuery);
      mediaListener.current = handleMediaQuery;
      reactExports.useEffect(() => {
        const handler = (...args) => mediaListener.current(...args);

        // Always listen to System preference
        const media = window.matchMedia('(prefers-color-scheme: dark)');

        // Intentionally use deprecated listener methods to support iOS & old browsers
        media.addListener(handler);
        handler(media);
        return () => media.removeListener(handler);
      }, []);

      // Handle when localStorage has changed
      reactExports.useEffect(() => {
        const handleStorage = event => {
          const value = event.newValue;
          if (typeof event.key === 'string' && event.key.startsWith(colorSchemeStorageKey) && (!value || joinedColorSchemes.match(value))) {
            // If the key is deleted, value will be null then reset color scheme to the default one.
            if (event.key.endsWith('light')) {
              setColorScheme({
                light: value
              });
            }
            if (event.key.endsWith('dark')) {
              setColorScheme({
                dark: value
              });
            }
          }
          if (event.key === modeStorageKey && (!value || ['light', 'dark', 'system'].includes(value))) {
            setMode(value || defaultMode);
          }
        };
        if (storageWindow) {
          // For syncing color-scheme changes between iframes
          storageWindow.addEventListener('storage', handleStorage);
          return () => storageWindow.removeEventListener('storage', handleStorage);
        }
        return undefined;
      }, [setColorScheme, setMode, modeStorageKey, colorSchemeStorageKey, joinedColorSchemes, defaultMode, storageWindow]);
      return _extends$2({}, state, {
        colorScheme,
        setMode,
        setColorScheme
      });
    }

    const _excluded$b = ["colorSchemes", "components", "generateCssVars", "cssVarPrefix"];
    const DISABLE_CSS_TRANSITION = '*{-webkit-transition:none!important;-moz-transition:none!important;-o-transition:none!important;-ms-transition:none!important;transition:none!important}';
    function createCssVarsProvider(options) {
      const {
        themeId,
        /**
         * This `theme` object needs to follow a certain structure to
         * be used correctly by the finel `CssVarsProvider`. It should have a
         * `colorSchemes` key with the light and dark (and any other) palette.
         * It should also ideally have a vars object created using `prepareCssVars`.
         */
        theme: defaultTheme = {},
        attribute: defaultAttribute = DEFAULT_ATTRIBUTE,
        modeStorageKey: defaultModeStorageKey = DEFAULT_MODE_STORAGE_KEY,
        colorSchemeStorageKey: defaultColorSchemeStorageKey = DEFAULT_COLOR_SCHEME_STORAGE_KEY,
        defaultMode: designSystemMode = 'light',
        defaultColorScheme: designSystemColorScheme,
        disableTransitionOnChange: designSystemTransitionOnChange = false,
        resolveTheme,
        excludeVariablesFromRoot
      } = options;
      if (!defaultTheme.colorSchemes || typeof designSystemColorScheme === 'string' && !defaultTheme.colorSchemes[designSystemColorScheme] || typeof designSystemColorScheme === 'object' && !defaultTheme.colorSchemes[designSystemColorScheme == null ? void 0 : designSystemColorScheme.light] || typeof designSystemColorScheme === 'object' && !defaultTheme.colorSchemes[designSystemColorScheme == null ? void 0 : designSystemColorScheme.dark]) {
        console.error(`MUI: \`${designSystemColorScheme}\` does not exist in \`theme.colorSchemes\`.`);
      }
      const ColorSchemeContext = /*#__PURE__*/reactExports.createContext(undefined);
      const useColorScheme = () => {
        const value = reactExports.useContext(ColorSchemeContext);
        if (!value) {
          throw new Error(formatMuiErrorMessage(19));
        }
        return value;
      };
      function CssVarsProvider({
        children,
        theme: themeProp = defaultTheme,
        modeStorageKey = defaultModeStorageKey,
        colorSchemeStorageKey = defaultColorSchemeStorageKey,
        attribute = defaultAttribute,
        defaultMode = designSystemMode,
        defaultColorScheme = designSystemColorScheme,
        disableTransitionOnChange = designSystemTransitionOnChange,
        storageWindow = window,
        documentNode = typeof document === 'undefined' ? undefined : document,
        colorSchemeNode = typeof document === 'undefined' ? undefined : document.documentElement,
        colorSchemeSelector = ':root',
        disableNestedContext = false,
        disableStyleSheetGeneration = false
      }) {
        const hasMounted = reactExports.useRef(false);
        const upperTheme = useTheme();
        const ctx = reactExports.useContext(ColorSchemeContext);
        const nested = !!ctx && !disableNestedContext;
        const scopedTheme = themeProp[themeId];
        const _ref = scopedTheme || themeProp,
          {
            colorSchemes = {},
            components = {},
            generateCssVars = () => ({
              vars: {},
              css: {}
            }),
            cssVarPrefix
          } = _ref,
          restThemeProp = _objectWithoutPropertiesLoose$1(_ref, _excluded$b);
        const allColorSchemes = Object.keys(colorSchemes);
        const defaultLightColorScheme = typeof defaultColorScheme === 'string' ? defaultColorScheme : defaultColorScheme.light;
        const defaultDarkColorScheme = typeof defaultColorScheme === 'string' ? defaultColorScheme : defaultColorScheme.dark;

        // 1. Get the data about the `mode`, `colorScheme`, and setter functions.
        const {
          mode: stateMode,
          setMode,
          systemMode,
          lightColorScheme,
          darkColorScheme,
          colorScheme: stateColorScheme,
          setColorScheme
        } = useCurrentColorScheme({
          supportedColorSchemes: allColorSchemes,
          defaultLightColorScheme,
          defaultDarkColorScheme,
          modeStorageKey,
          colorSchemeStorageKey,
          defaultMode,
          storageWindow
        });
        let mode = stateMode;
        let colorScheme = stateColorScheme;
        if (nested) {
          mode = ctx.mode;
          colorScheme = ctx.colorScheme;
        }
        const calculatedMode = (() => {
          if (mode) {
            return mode;
          }
          // This scope occurs on the server
          if (defaultMode === 'system') {
            return designSystemMode;
          }
          return defaultMode;
        })();
        const calculatedColorScheme = (() => {
          if (!colorScheme) {
            // This scope occurs on the server
            if (calculatedMode === 'dark') {
              return defaultDarkColorScheme;
            }
            // use light color scheme, if default mode is 'light' | 'system'
            return defaultLightColorScheme;
          }
          return colorScheme;
        })();

        // 2. Create CSS variables and store them in objects (to be generated in stylesheets in the final step)
        const {
          css: rootCss,
          vars: rootVars
        } = generateCssVars();

        // 3. Start composing the theme object
        const theme = _extends$2({}, restThemeProp, {
          components,
          colorSchemes,
          cssVarPrefix,
          vars: rootVars,
          getColorSchemeSelector: targetColorScheme => `[${attribute}="${targetColorScheme}"] &`
        });

        // 4. Create color CSS variables and store them in objects (to be generated in stylesheets in the final step)
        //    The default color scheme stylesheet is constructed to have the least CSS specificity.
        //    The other color schemes uses selector, default as data attribute, to increase the CSS specificity so that they can override the default color scheme stylesheet.
        const defaultColorSchemeStyleSheet = {};
        const otherColorSchemesStyleSheet = {};
        Object.entries(colorSchemes).forEach(([key, scheme]) => {
          const {
            css,
            vars
          } = generateCssVars(key);
          theme.vars = deepmerge(theme.vars, vars);
          if (key === calculatedColorScheme) {
            // 4.1 Merge the selected color scheme to the theme
            Object.keys(scheme).forEach(schemeKey => {
              if (scheme[schemeKey] && typeof scheme[schemeKey] === 'object') {
                // shallow merge the 1st level structure of the theme.
                theme[schemeKey] = _extends$2({}, theme[schemeKey], scheme[schemeKey]);
              } else {
                theme[schemeKey] = scheme[schemeKey];
              }
            });
            if (theme.palette) {
              theme.palette.colorScheme = key;
            }
          }
          const resolvedDefaultColorScheme = (() => {
            if (typeof defaultColorScheme === 'string') {
              return defaultColorScheme;
            }
            if (defaultMode === 'dark') {
              return defaultColorScheme.dark;
            }
            return defaultColorScheme.light;
          })();
          if (key === resolvedDefaultColorScheme) {
            if (excludeVariablesFromRoot) {
              const excludedVariables = {};
              excludeVariablesFromRoot(cssVarPrefix).forEach(cssVar => {
                excludedVariables[cssVar] = css[cssVar];
                delete css[cssVar];
              });
              defaultColorSchemeStyleSheet[`[${attribute}="${key}"]`] = excludedVariables;
            }
            defaultColorSchemeStyleSheet[`${colorSchemeSelector}, [${attribute}="${key}"]`] = css;
          } else {
            otherColorSchemesStyleSheet[`${colorSchemeSelector === ':root' ? '' : colorSchemeSelector}[${attribute}="${key}"]`] = css;
          }
        });
        theme.vars = deepmerge(theme.vars, rootVars);

        // 5. Declaring effects
        // 5.1 Updates the selector value to use the current color scheme which tells CSS to use the proper stylesheet.
        reactExports.useEffect(() => {
          if (colorScheme && colorSchemeNode) {
            // attaches attribute to <html> because the css variables are attached to :root (html)
            colorSchemeNode.setAttribute(attribute, colorScheme);
          }
        }, [colorScheme, attribute, colorSchemeNode]);

        // 5.2 Remove the CSS transition when color scheme changes to create instant experience.
        // credit: https://github.com/pacocoursey/next-themes/blob/b5c2bad50de2d61ad7b52a9c5cdc801a78507d7a/index.tsx#L313
        reactExports.useEffect(() => {
          let timer;
          if (disableTransitionOnChange && hasMounted.current && documentNode) {
            const css = documentNode.createElement('style');
            css.appendChild(documentNode.createTextNode(DISABLE_CSS_TRANSITION));
            documentNode.head.appendChild(css);

            // Force browser repaint
            (() => window.getComputedStyle(documentNode.body))();
            timer = setTimeout(() => {
              documentNode.head.removeChild(css);
            }, 1);
          }
          return () => {
            clearTimeout(timer);
          };
        }, [colorScheme, disableTransitionOnChange, documentNode]);
        reactExports.useEffect(() => {
          hasMounted.current = true;
          return () => {
            hasMounted.current = false;
          };
        }, []);
        const contextValue = reactExports.useMemo(() => ({
          mode,
          systemMode,
          setMode,
          lightColorScheme,
          darkColorScheme,
          colorScheme,
          setColorScheme,
          allColorSchemes
        }), [allColorSchemes, colorScheme, darkColorScheme, lightColorScheme, mode, setColorScheme, setMode, systemMode]);
        let shouldGenerateStyleSheet = true;
        if (disableStyleSheetGeneration || nested && (upperTheme == null ? void 0 : upperTheme.cssVarPrefix) === cssVarPrefix) {
          shouldGenerateStyleSheet = false;
        }
        const element = /*#__PURE__*/jsxRuntimeExports.jsxs(reactExports.Fragment, {
          children: [shouldGenerateStyleSheet && /*#__PURE__*/jsxRuntimeExports.jsxs(reactExports.Fragment, {
            children: [/*#__PURE__*/jsxRuntimeExports.jsx(GlobalStyles$2, {
              styles: {
                [colorSchemeSelector]: rootCss
              }
            }), /*#__PURE__*/jsxRuntimeExports.jsx(GlobalStyles$2, {
              styles: defaultColorSchemeStyleSheet
            }), /*#__PURE__*/jsxRuntimeExports.jsx(GlobalStyles$2, {
              styles: otherColorSchemesStyleSheet
            })]
          }), /*#__PURE__*/jsxRuntimeExports.jsx(ThemeProvider$1, {
            themeId: scopedTheme ? themeId : undefined,
            theme: resolveTheme ? resolveTheme(theme) : theme,
            children: children
          })]
        });
        if (nested) {
          return element;
        }
        return /*#__PURE__*/jsxRuntimeExports.jsx(ColorSchemeContext.Provider, {
          value: contextValue,
          children: element
        });
      }
      const defaultLightColorScheme = typeof designSystemColorScheme === 'string' ? designSystemColorScheme : designSystemColorScheme.light;
      const defaultDarkColorScheme = typeof designSystemColorScheme === 'string' ? designSystemColorScheme : designSystemColorScheme.dark;
      const getInitColorSchemeScript$1 = params => getInitColorSchemeScript(_extends$2({
        attribute: defaultAttribute,
        colorSchemeStorageKey: defaultColorSchemeStorageKey,
        defaultMode: designSystemMode,
        defaultLightColorScheme,
        defaultDarkColorScheme,
        modeStorageKey: defaultModeStorageKey
      }, params));
      return {
        CssVarsProvider,
        useColorScheme,
        getInitColorSchemeScript: getInitColorSchemeScript$1
      };
    }

    /**
     * The benefit of this function is to help developers get CSS var from theme without specifying the whole variable
     * and they does not need to remember the prefix (defined once).
     */
    function createGetCssVar$1(prefix = '') {
      function appendVar(...vars) {
        if (!vars.length) {
          return '';
        }
        const value = vars[0];
        if (typeof value === 'string' && !value.match(/(#|\(|\)|(-?(\d*\.)?\d+)(px|em|%|ex|ch|rem|vw|vh|vmin|vmax|cm|mm|in|pt|pc))|^(-?(\d*\.)?\d+)$|(\d+ \d+ \d+)/)) {
          return `, var(--${prefix ? `${prefix}-` : ''}${value}${appendVar(...vars.slice(1))})`;
        }
        return `, ${value}`;
      }

      // AdditionalVars makes `getCssVar` less strict, so it can be use like this `getCssVar('non-mui-variable')` without type error.
      const getCssVar = (field, ...fallbacks) => {
        return `var(--${prefix ? `${prefix}-` : ''}${field}${appendVar(...fallbacks)})`;
      };
      return getCssVar;
    }

    /**
     * This function create an object from keys, value and then assign to target
     *
     * @param {Object} obj : the target object to be assigned
     * @param {string[]} keys
     * @param {string | number} value
     *
     * @example
     * const source = {}
     * assignNestedKeys(source, ['palette', 'primary'], 'var(--palette-primary)')
     * console.log(source) // { palette: { primary: 'var(--palette-primary)' } }
     *
     * @example
     * const source = { palette: { primary: 'var(--palette-primary)' } }
     * assignNestedKeys(source, ['palette', 'secondary'], 'var(--palette-secondary)')
     * console.log(source) // { palette: { primary: 'var(--palette-primary)', secondary: 'var(--palette-secondary)' } }
     */
    const assignNestedKeys = (obj, keys, value, arrayKeys = []) => {
      let temp = obj;
      keys.forEach((k, index) => {
        if (index === keys.length - 1) {
          if (Array.isArray(temp)) {
            temp[Number(k)] = value;
          } else if (temp && typeof temp === 'object') {
            temp[k] = value;
          }
        } else if (temp && typeof temp === 'object') {
          if (!temp[k]) {
            temp[k] = arrayKeys.includes(k) ? [] : {};
          }
          temp = temp[k];
        }
      });
    };

    /**
     *
     * @param {Object} obj : source object
     * @param {Function} callback : a function that will be called when
     *                   - the deepest key in source object is reached
     *                   - the value of the deepest key is NOT `undefined` | `null`
     *
     * @example
     * walkObjectDeep({ palette: { primary: { main: '#000000' } } }, console.log)
     * // ['palette', 'primary', 'main'] '#000000'
     */
    const walkObjectDeep = (obj, callback, shouldSkipPaths) => {
      function recurse(object, parentKeys = [], arrayKeys = []) {
        Object.entries(object).forEach(([key, value]) => {
          if (!shouldSkipPaths || shouldSkipPaths && !shouldSkipPaths([...parentKeys, key])) {
            if (value !== undefined && value !== null) {
              if (typeof value === 'object' && Object.keys(value).length > 0) {
                recurse(value, [...parentKeys, key], Array.isArray(value) ? [...arrayKeys, key] : arrayKeys);
              } else {
                callback([...parentKeys, key], value, arrayKeys);
              }
            }
          }
        });
      }
      recurse(obj);
    };
    const getCssValue = (keys, value) => {
      if (typeof value === 'number') {
        if (['lineHeight', 'fontWeight', 'opacity', 'zIndex'].some(prop => keys.includes(prop))) {
          // CSS property that are unitless
          return value;
        }
        const lastKey = keys[keys.length - 1];
        if (lastKey.toLowerCase().indexOf('opacity') >= 0) {
          // opacity values are unitless
          return value;
        }
        return `${value}px`;
      }
      return value;
    };

    /**
     * a function that parse theme and return { css, vars }
     *
     * @param {Object} theme
     * @param {{
     *  prefix?: string,
     *  shouldSkipGeneratingVar?: (objectPathKeys: Array<string>, value: string | number) => boolean
     * }} options.
     *  `prefix`: The prefix of the generated CSS variables. This function does not change the value.
     *
     * @returns {{ css: Object, vars: Object }} `css` is the stylesheet, `vars` is an object to get css variable (same structure as theme).
     *
     * @example
     * const { css, vars } = parser({
     *   fontSize: 12,
     *   lineHeight: 1.2,
     *   palette: { primary: { 500: 'var(--color)' } }
     * }, { prefix: 'foo' })
     *
     * console.log(css) // { '--foo-fontSize': '12px', '--foo-lineHeight': 1.2, '--foo-palette-primary-500': 'var(--color)' }
     * console.log(vars) // { fontSize: 'var(--foo-fontSize)', lineHeight: 'var(--foo-lineHeight)', palette: { primary: { 500: 'var(--foo-palette-primary-500)' } } }
     */
    function cssVarsParser(theme, options) {
      const {
        prefix,
        shouldSkipGeneratingVar
      } = options || {};
      const css = {};
      const vars = {};
      const varsWithDefaults = {};
      walkObjectDeep(theme, (keys, value, arrayKeys) => {
        if (typeof value === 'string' || typeof value === 'number') {
          if (!shouldSkipGeneratingVar || !shouldSkipGeneratingVar(keys, value)) {
            // only create css & var if `shouldSkipGeneratingVar` return false
            const cssVar = `--${prefix ? `${prefix}-` : ''}${keys.join('-')}`;
            Object.assign(css, {
              [cssVar]: getCssValue(keys, value)
            });
            assignNestedKeys(vars, keys, `var(${cssVar})`, arrayKeys);
            assignNestedKeys(varsWithDefaults, keys, `var(${cssVar}, ${value})`, arrayKeys);
          }
        }
      }, keys => keys[0] === 'vars' // skip 'vars/*' paths
      );

      return {
        css,
        vars,
        varsWithDefaults
      };
    }

    const _excluded$a = ["colorSchemes", "components"],
      _excluded2$1 = ["light"];
    function prepareCssVars(theme, parserConfig) {
      // @ts-ignore - ignore components do not exist
      const {
          colorSchemes = {}
        } = theme,
        otherTheme = _objectWithoutPropertiesLoose$1(theme, _excluded$a);
      const {
        vars: rootVars,
        css: rootCss,
        varsWithDefaults: rootVarsWithDefaults
      } = cssVarsParser(otherTheme, parserConfig);
      let themeVars = rootVarsWithDefaults;
      const colorSchemesMap = {};
      const {
          light
        } = colorSchemes,
        otherColorSchemes = _objectWithoutPropertiesLoose$1(colorSchemes, _excluded2$1);
      Object.entries(otherColorSchemes || {}).forEach(([key, scheme]) => {
        const {
          vars,
          css,
          varsWithDefaults
        } = cssVarsParser(scheme, parserConfig);
        themeVars = deepmerge(themeVars, varsWithDefaults);
        colorSchemesMap[key] = {
          css,
          vars
        };
      });
      if (light) {
        // light color scheme vars should be merged last to set as default
        const {
          css,
          vars,
          varsWithDefaults
        } = cssVarsParser(light, parserConfig);
        themeVars = deepmerge(themeVars, varsWithDefaults);
        colorSchemesMap.light = {
          css,
          vars
        };
      }
      const generateCssVars = colorScheme => {
        if (!colorScheme) {
          return {
            css: _extends$2({}, rootCss),
            vars: rootVars
          };
        }
        return {
          css: _extends$2({}, colorSchemesMap[colorScheme].css),
          vars: colorSchemesMap[colorScheme].vars
        };
      };
      return {
        vars: themeVars,
        generateCssVars
      };
    }

    function createMixins(breakpoints, mixins) {
      return _extends$4({
        toolbar: {
          minHeight: 56,
          [breakpoints.up('xs')]: {
            '@media (orientation: landscape)': {
              minHeight: 48
            }
          },
          [breakpoints.up('sm')]: {
            minHeight: 64
          }
        }
      }, mixins);
    }

    const _excluded$9 = ["mode", "contrastThreshold", "tonalOffset"];
    const light = {
      // The colors used to style the text.
      text: {
        // The most important text.
        primary: 'rgba(0, 0, 0, 0.87)',
        // Secondary text.
        secondary: 'rgba(0, 0, 0, 0.6)',
        // Disabled text have even lower visual prominence.
        disabled: 'rgba(0, 0, 0, 0.38)'
      },
      // The color used to divide different elements.
      divider: 'rgba(0, 0, 0, 0.12)',
      // The background colors used to style the surfaces.
      // Consistency between these values is important.
      background: {
        paper: common.white,
        default: common.white
      },
      // The colors used to style the action elements.
      action: {
        // The color of an active action like an icon button.
        active: 'rgba(0, 0, 0, 0.54)',
        // The color of an hovered action.
        hover: 'rgba(0, 0, 0, 0.04)',
        hoverOpacity: 0.04,
        // The color of a selected action.
        selected: 'rgba(0, 0, 0, 0.08)',
        selectedOpacity: 0.08,
        // The color of a disabled action.
        disabled: 'rgba(0, 0, 0, 0.26)',
        // The background color of a disabled action.
        disabledBackground: 'rgba(0, 0, 0, 0.12)',
        disabledOpacity: 0.38,
        focus: 'rgba(0, 0, 0, 0.12)',
        focusOpacity: 0.12,
        activatedOpacity: 0.12
      }
    };
    const dark = {
      text: {
        primary: common.white,
        secondary: 'rgba(255, 255, 255, 0.7)',
        disabled: 'rgba(255, 255, 255, 0.5)',
        icon: 'rgba(255, 255, 255, 0.5)'
      },
      divider: 'rgba(255, 255, 255, 0.12)',
      background: {
        paper: '#121212',
        default: '#121212'
      },
      action: {
        active: common.white,
        hover: 'rgba(255, 255, 255, 0.08)',
        hoverOpacity: 0.08,
        selected: 'rgba(255, 255, 255, 0.16)',
        selectedOpacity: 0.16,
        disabled: 'rgba(255, 255, 255, 0.3)',
        disabledBackground: 'rgba(255, 255, 255, 0.12)',
        disabledOpacity: 0.38,
        focus: 'rgba(255, 255, 255, 0.12)',
        focusOpacity: 0.12,
        activatedOpacity: 0.24
      }
    };
    function addLightOrDark(intent, direction, shade, tonalOffset) {
      const tonalOffsetLight = tonalOffset.light || tonalOffset;
      const tonalOffsetDark = tonalOffset.dark || tonalOffset * 1.5;
      if (!intent[direction]) {
        if (intent.hasOwnProperty(shade)) {
          intent[direction] = intent[shade];
        } else if (direction === 'light') {
          intent.light = lighten(intent.main, tonalOffsetLight);
        } else if (direction === 'dark') {
          intent.dark = darken(intent.main, tonalOffsetDark);
        }
      }
    }
    function getDefaultPrimary(mode = 'light') {
      if (mode === 'dark') {
        return {
          main: blue[200],
          light: blue[50],
          dark: blue[400]
        };
      }
      return {
        main: blue[700],
        light: blue[400],
        dark: blue[800]
      };
    }
    function getDefaultSecondary(mode = 'light') {
      if (mode === 'dark') {
        return {
          main: purple[200],
          light: purple[50],
          dark: purple[400]
        };
      }
      return {
        main: purple[500],
        light: purple[300],
        dark: purple[700]
      };
    }
    function getDefaultError(mode = 'light') {
      if (mode === 'dark') {
        return {
          main: red[500],
          light: red[300],
          dark: red[700]
        };
      }
      return {
        main: red[700],
        light: red[400],
        dark: red[800]
      };
    }
    function getDefaultInfo(mode = 'light') {
      if (mode === 'dark') {
        return {
          main: lightBlue[400],
          light: lightBlue[300],
          dark: lightBlue[700]
        };
      }
      return {
        main: lightBlue[700],
        light: lightBlue[500],
        dark: lightBlue[900]
      };
    }
    function getDefaultSuccess(mode = 'light') {
      if (mode === 'dark') {
        return {
          main: green[400],
          light: green[300],
          dark: green[700]
        };
      }
      return {
        main: green[800],
        light: green[500],
        dark: green[900]
      };
    }
    function getDefaultWarning(mode = 'light') {
      if (mode === 'dark') {
        return {
          main: orange[400],
          light: orange[300],
          dark: orange[700]
        };
      }
      return {
        main: '#ed6c02',
        // closest to orange[800] that pass 3:1.
        light: orange[500],
        dark: orange[900]
      };
    }
    function createPalette(palette) {
      const {
          mode = 'light',
          contrastThreshold = 3,
          tonalOffset = 0.2
        } = palette,
        other = _objectWithoutPropertiesLoose$2(palette, _excluded$9);
      const primary = palette.primary || getDefaultPrimary(mode);
      const secondary = palette.secondary || getDefaultSecondary(mode);
      const error = palette.error || getDefaultError(mode);
      const info = palette.info || getDefaultInfo(mode);
      const success = palette.success || getDefaultSuccess(mode);
      const warning = palette.warning || getDefaultWarning(mode);

      // Use the same logic as
      // Bootstrap: https://github.com/twbs/bootstrap/blob/1d6e3710dd447de1a200f29e8fa521f8a0908f70/scss/_functions.scss#L59
      // and material-components-web https://github.com/material-components/material-components-web/blob/ac46b8863c4dab9fc22c4c662dc6bd1b65dd652f/packages/mdc-theme/_functions.scss#L54
      function getContrastText(background) {
        const contrastText = getContrastRatio(background, dark.text.primary) >= contrastThreshold ? dark.text.primary : light.text.primary;
        return contrastText;
      }
      const augmentColor = ({
        color,
        name,
        mainShade = 500,
        lightShade = 300,
        darkShade = 700
      }) => {
        color = _extends$4({}, color);
        if (!color.main && color[mainShade]) {
          color.main = color[mainShade];
        }
        if (!color.hasOwnProperty('main')) {
          throw new Error(formatMuiErrorMessage(11, name ? ` (${name})` : '', mainShade));
        }
        if (typeof color.main !== 'string') {
          throw new Error(formatMuiErrorMessage(12, name ? ` (${name})` : '', JSON.stringify(color.main)));
        }
        addLightOrDark(color, 'light', lightShade, tonalOffset);
        addLightOrDark(color, 'dark', darkShade, tonalOffset);
        if (!color.contrastText) {
          color.contrastText = getContrastText(color.main);
        }
        return color;
      };
      const modes = {
        dark,
        light
      };
      const paletteOutput = deepmerge(_extends$4({
        // A collection of common colors.
        common: _extends$4({}, common),
        // prevent mutable object.
        // The palette mode, can be light or dark.
        mode,
        // The colors used to represent primary interface elements for a user.
        primary: augmentColor({
          color: primary,
          name: 'primary'
        }),
        // The colors used to represent secondary interface elements for a user.
        secondary: augmentColor({
          color: secondary,
          name: 'secondary',
          mainShade: 'A400',
          lightShade: 'A200',
          darkShade: 'A700'
        }),
        // The colors used to represent interface elements that the user should be made aware of.
        error: augmentColor({
          color: error,
          name: 'error'
        }),
        // The colors used to represent potentially dangerous actions or important messages.
        warning: augmentColor({
          color: warning,
          name: 'warning'
        }),
        // The colors used to present information to the user that is neutral and not necessarily important.
        info: augmentColor({
          color: info,
          name: 'info'
        }),
        // The colors used to indicate the successful completion of an action that user triggered.
        success: augmentColor({
          color: success,
          name: 'success'
        }),
        // The grey colors.
        grey,
        // Used by `getContrastText()` to maximize the contrast between
        // the background and the text.
        contrastThreshold,
        // Takes a background color and returns the text color that maximizes the contrast.
        getContrastText,
        // Generate a rich color object.
        augmentColor,
        // Used by the functions below to shift a color's luminance by approximately
        // two indexes within its tonal palette.
        // E.g., shift from Red 500 to Red 300 or Red 700.
        tonalOffset
      }, modes[mode]), other);
      return paletteOutput;
    }

    const _excluded$8 = ["fontFamily", "fontSize", "fontWeightLight", "fontWeightRegular", "fontWeightMedium", "fontWeightBold", "htmlFontSize", "allVariants", "pxToRem"];
    function round(value) {
      return Math.round(value * 1e5) / 1e5;
    }
    const caseAllCaps = {
      textTransform: 'uppercase'
    };
    const defaultFontFamily = '"Roboto", "Helvetica", "Arial", sans-serif';

    /**
     * @see @link{https://m2.material.io/design/typography/the-type-system.html}
     * @see @link{https://m2.material.io/design/typography/understanding-typography.html}
     */
    function createTypography(palette, typography) {
      const _ref = typeof typography === 'function' ? typography(palette) : typography,
        {
          fontFamily = defaultFontFamily,
          // The default font size of the Material Specification.
          fontSize = 14,
          // px
          fontWeightLight = 300,
          fontWeightRegular = 400,
          fontWeightMedium = 500,
          fontWeightBold = 700,
          // Tell MUI what's the font-size on the html element.
          // 16px is the default font-size used by browsers.
          htmlFontSize = 16,
          // Apply the CSS properties to all the variants.
          allVariants,
          pxToRem: pxToRem2
        } = _ref,
        other = _objectWithoutPropertiesLoose$2(_ref, _excluded$8);
      const coef = fontSize / 14;
      const pxToRem = pxToRem2 || (size => `${size / htmlFontSize * coef}rem`);
      const buildVariant = (fontWeight, size, lineHeight, letterSpacing, casing) => _extends$4({
        fontFamily,
        fontWeight,
        fontSize: pxToRem(size),
        // Unitless following https://meyerweb.com/eric/thoughts/2006/02/08/unitless-line-heights/
        lineHeight
      }, fontFamily === defaultFontFamily ? {
        letterSpacing: `${round(letterSpacing / size)}em`
      } : {}, casing, allVariants);
      const variants = {
        h1: buildVariant(fontWeightLight, 96, 1.167, -1.5),
        h2: buildVariant(fontWeightLight, 60, 1.2, -0.5),
        h3: buildVariant(fontWeightRegular, 48, 1.167, 0),
        h4: buildVariant(fontWeightRegular, 34, 1.235, 0.25),
        h5: buildVariant(fontWeightRegular, 24, 1.334, 0),
        h6: buildVariant(fontWeightMedium, 20, 1.6, 0.15),
        subtitle1: buildVariant(fontWeightRegular, 16, 1.75, 0.15),
        subtitle2: buildVariant(fontWeightMedium, 14, 1.57, 0.1),
        body1: buildVariant(fontWeightRegular, 16, 1.5, 0.15),
        body2: buildVariant(fontWeightRegular, 14, 1.43, 0.15),
        button: buildVariant(fontWeightMedium, 14, 1.75, 0.4, caseAllCaps),
        caption: buildVariant(fontWeightRegular, 12, 1.66, 0.4),
        overline: buildVariant(fontWeightRegular, 12, 2.66, 1, caseAllCaps),
        inherit: {
          fontFamily: 'inherit',
          fontWeight: 'inherit',
          fontSize: 'inherit',
          lineHeight: 'inherit',
          letterSpacing: 'inherit'
        }
      };
      return deepmerge(_extends$4({
        htmlFontSize,
        pxToRem,
        fontFamily,
        fontSize,
        fontWeightLight,
        fontWeightRegular,
        fontWeightMedium,
        fontWeightBold
      }, variants), other, {
        clone: false // No need to clone deep
      });
    }

    const shadowKeyUmbraOpacity = 0.2;
    const shadowKeyPenumbraOpacity = 0.14;
    const shadowAmbientShadowOpacity = 0.12;
    function createShadow(...px) {
      return [`${px[0]}px ${px[1]}px ${px[2]}px ${px[3]}px rgba(0,0,0,${shadowKeyUmbraOpacity})`, `${px[4]}px ${px[5]}px ${px[6]}px ${px[7]}px rgba(0,0,0,${shadowKeyPenumbraOpacity})`, `${px[8]}px ${px[9]}px ${px[10]}px ${px[11]}px rgba(0,0,0,${shadowAmbientShadowOpacity})`].join(',');
    }

    // Values from https://github.com/material-components/material-components-web/blob/be8747f94574669cb5e7add1a7c54fa41a89cec7/packages/mdc-elevation/_variables.scss
    const shadows = ['none', createShadow(0, 2, 1, -1, 0, 1, 1, 0, 0, 1, 3, 0), createShadow(0, 3, 1, -2, 0, 2, 2, 0, 0, 1, 5, 0), createShadow(0, 3, 3, -2, 0, 3, 4, 0, 0, 1, 8, 0), createShadow(0, 2, 4, -1, 0, 4, 5, 0, 0, 1, 10, 0), createShadow(0, 3, 5, -1, 0, 5, 8, 0, 0, 1, 14, 0), createShadow(0, 3, 5, -1, 0, 6, 10, 0, 0, 1, 18, 0), createShadow(0, 4, 5, -2, 0, 7, 10, 1, 0, 2, 16, 1), createShadow(0, 5, 5, -3, 0, 8, 10, 1, 0, 3, 14, 2), createShadow(0, 5, 6, -3, 0, 9, 12, 1, 0, 3, 16, 2), createShadow(0, 6, 6, -3, 0, 10, 14, 1, 0, 4, 18, 3), createShadow(0, 6, 7, -4, 0, 11, 15, 1, 0, 4, 20, 3), createShadow(0, 7, 8, -4, 0, 12, 17, 2, 0, 5, 22, 4), createShadow(0, 7, 8, -4, 0, 13, 19, 2, 0, 5, 24, 4), createShadow(0, 7, 9, -4, 0, 14, 21, 2, 0, 5, 26, 4), createShadow(0, 8, 9, -5, 0, 15, 22, 2, 0, 6, 28, 5), createShadow(0, 8, 10, -5, 0, 16, 24, 2, 0, 6, 30, 5), createShadow(0, 8, 11, -5, 0, 17, 26, 2, 0, 6, 32, 5), createShadow(0, 9, 11, -5, 0, 18, 28, 2, 0, 7, 34, 6), createShadow(0, 9, 12, -6, 0, 19, 29, 2, 0, 7, 36, 6), createShadow(0, 10, 13, -6, 0, 20, 31, 3, 0, 8, 38, 7), createShadow(0, 10, 13, -6, 0, 21, 33, 3, 0, 8, 40, 7), createShadow(0, 10, 14, -6, 0, 22, 35, 3, 0, 8, 42, 7), createShadow(0, 11, 14, -7, 0, 23, 36, 3, 0, 9, 44, 8), createShadow(0, 11, 15, -7, 0, 24, 38, 3, 0, 9, 46, 8)];

    const _excluded$7 = ["duration", "easing", "delay"];
    // Follow https://material.google.com/motion/duration-easing.html#duration-easing-natural-easing-curves
    // to learn the context in which each easing should be used.
    const easing = {
      // This is the most common easing curve.
      easeInOut: 'cubic-bezier(0.4, 0, 0.2, 1)',
      // Objects enter the screen at full velocity from off-screen and
      // slowly decelerate to a resting point.
      easeOut: 'cubic-bezier(0.0, 0, 0.2, 1)',
      // Objects leave the screen at full velocity. They do not decelerate when off-screen.
      easeIn: 'cubic-bezier(0.4, 0, 1, 1)',
      // The sharp curve is used by objects that may return to the screen at any time.
      sharp: 'cubic-bezier(0.4, 0, 0.6, 1)'
    };

    // Follow https://m2.material.io/guidelines/motion/duration-easing.html#duration-easing-common-durations
    // to learn when use what timing
    const duration = {
      shortest: 150,
      shorter: 200,
      short: 250,
      // most basic recommended timing
      standard: 300,
      // this is to be used in complex animations
      complex: 375,
      // recommended when something is entering screen
      enteringScreen: 225,
      // recommended when something is leaving screen
      leavingScreen: 195
    };
    function formatMs(milliseconds) {
      return `${Math.round(milliseconds)}ms`;
    }
    function getAutoHeightDuration(height) {
      if (!height) {
        return 0;
      }
      const constant = height / 36;

      // https://www.wolframalpha.com/input/?i=(4+%2B+15+*+(x+%2F+36+)+**+0.25+%2B+(x+%2F+36)+%2F+5)+*+10
      return Math.round((4 + 15 * constant ** 0.25 + constant / 5) * 10);
    }
    function createTransitions(inputTransitions) {
      const mergedEasing = _extends$4({}, easing, inputTransitions.easing);
      const mergedDuration = _extends$4({}, duration, inputTransitions.duration);
      const create = (props = ['all'], options = {}) => {
        const {
            duration: durationOption = mergedDuration.standard,
            easing: easingOption = mergedEasing.easeInOut,
            delay = 0
          } = options;
          _objectWithoutPropertiesLoose$2(options, _excluded$7);
        return (Array.isArray(props) ? props : [props]).map(animatedProp => `${animatedProp} ${typeof durationOption === 'string' ? durationOption : formatMs(durationOption)} ${easingOption} ${typeof delay === 'string' ? delay : formatMs(delay)}`).join(',');
      };
      return _extends$4({
        getAutoHeightDuration,
        create
      }, inputTransitions, {
        easing: mergedEasing,
        duration: mergedDuration
      });
    }

    // We need to centralize the zIndex definitions as they work
    // like global values in the browser.
    const zIndex = {
      mobileStepper: 1000,
      fab: 1050,
      speedDial: 1050,
      appBar: 1100,
      drawer: 1200,
      modal: 1300,
      snackbar: 1400,
      tooltip: 1500
    };

    const _excluded$6 = ["breakpoints", "mixins", "spacing", "palette", "transitions", "typography", "shape"];
    function createTheme(options = {}, ...args) {
      const {
          mixins: mixinsInput = {},
          palette: paletteInput = {},
          transitions: transitionsInput = {},
          typography: typographyInput = {}
        } = options,
        other = _objectWithoutPropertiesLoose$2(options, _excluded$6);
      if (options.vars) {
        throw new Error(formatMuiErrorMessage(18));
      }
      const palette = createPalette(paletteInput);
      const systemTheme = createTheme$1(options);
      let muiTheme = deepmerge(systemTheme, {
        mixins: createMixins(systemTheme.breakpoints, mixinsInput),
        palette,
        // Don't use [...shadows] until you've verified its transpiled code is not invoking the iterator protocol.
        shadows: shadows.slice(),
        typography: createTypography(palette, typographyInput),
        transitions: createTransitions(transitionsInput),
        zIndex: _extends$4({}, zIndex)
      });
      muiTheme = deepmerge(muiTheme, other);
      muiTheme = args.reduce((acc, argument) => deepmerge(acc, argument), muiTheme);
      muiTheme.unstable_sxConfig = _extends$4({}, defaultSxConfig$1, other == null ? void 0 : other.unstable_sxConfig);
      muiTheme.unstable_sx = function sx(props) {
        return styleFunctionSx$1({
          sx: props,
          theme: this
        });
      };
      return muiTheme;
    }

    const defaultTheme$2 = createTheme();

    function useThemeProps({
      props,
      name
    }) {
      return useThemeProps$1({
        props,
        name,
        defaultTheme: defaultTheme$2,
        themeId: THEME_ID
      });
    }

    const rootShouldForwardProp = prop => shouldForwardProp(prop) && prop !== 'classes';
    const styled = createStyled({
      themeId: THEME_ID,
      defaultTheme: defaultTheme$2,
      rootShouldForwardProp
    });

    const _excluded$5 = ["theme"];
    function ThemeProvider(_ref) {
      let {
          theme: themeInput
        } = _ref,
        props = _objectWithoutPropertiesLoose$2(_ref, _excluded$5);
      const scopedTheme = themeInput[THEME_ID];
      return /*#__PURE__*/jsxRuntimeExports.jsx(ThemeProvider$1, _extends$4({}, props, {
        themeId: scopedTheme ? THEME_ID : undefined,
        theme: scopedTheme || themeInput
      }));
    }

    function shouldSkipGeneratingVar(keys) {
      var _keys$;
      return !!keys[0].match(/(cssVarPrefix|typography|mixins|breakpoints|direction|transitions)/) || !!keys[0].match(/sxConfig$/) ||
      // ends with sxConfig
      keys[0] === 'palette' && !!((_keys$ = keys[1]) != null && _keys$.match(/(mode|contrastThreshold|tonalOffset)/));
    }

    // Inspired by https://github.com/material-components/material-components-ios/blob/bca36107405594d5b7b16265a5b0ed698f85a5ee/components/Elevation/src/UIColor%2BMaterialElevation.m#L61
    const getOverlayAlpha = elevation => {
      let alphaValue;
      if (elevation < 1) {
        alphaValue = 5.11916 * elevation ** 2;
      } else {
        alphaValue = 4.5 * Math.log(elevation + 1) + 2;
      }
      return (alphaValue / 100).toFixed(2);
    };

    const _excluded$4 = ["colorSchemes", "cssVarPrefix", "shouldSkipGeneratingVar"],
      _excluded2 = ["palette"];
    const defaultDarkOverlays = [...Array(25)].map((_, index) => {
      if (index === 0) {
        return undefined;
      }
      const overlay = getOverlayAlpha(index);
      return `linear-gradient(rgba(255 255 255 / ${overlay}), rgba(255 255 255 / ${overlay}))`;
    });
    function assignNode(obj, keys) {
      keys.forEach(k => {
        if (!obj[k]) {
          obj[k] = {};
        }
      });
    }
    function setColor(obj, key, defaultValue) {
      if (!obj[key] && defaultValue) {
        obj[key] = defaultValue;
      }
    }
    function setColorChannel(obj, key) {
      if (!(`${key}Channel` in obj)) {
        // custom channel token is not provided, generate one.
        // if channel token can't be generated, show a warning.
        obj[`${key}Channel`] = private_safeColorChannel(obj[key], `MUI: Can't create \`palette.${key}Channel\` because \`palette.${key}\` is not one of these formats: #nnn, #nnnnnn, rgb(), rgba(), hsl(), hsla(), color().` + '\n' + `To suppress this warning, you need to explicitly provide the \`palette.${key}Channel\` as a string (in rgb format, e.g. "12 12 12") or undefined if you want to remove the channel token.`);
      }
    }
    const silent = fn => {
      try {
        return fn();
      } catch (error) {
        // ignore error
      }
      return undefined;
    };
    const createGetCssVar = (cssVarPrefix = 'mui') => createGetCssVar$1(cssVarPrefix);
    function extendTheme(options = {}, ...args) {
      var _colorSchemesInput$li, _colorSchemesInput$da, _colorSchemesInput$li2, _colorSchemesInput$li3, _colorSchemesInput$da2, _colorSchemesInput$da3;
      const {
          colorSchemes: colorSchemesInput = {},
          cssVarPrefix = 'mui',
          shouldSkipGeneratingVar: shouldSkipGeneratingVar$1 = shouldSkipGeneratingVar
        } = options,
        input = _objectWithoutPropertiesLoose$2(options, _excluded$4);
      const getCssVar = createGetCssVar(cssVarPrefix);
      const _createThemeWithoutVa = createTheme(_extends$4({}, input, colorSchemesInput.light && {
          palette: (_colorSchemesInput$li = colorSchemesInput.light) == null ? void 0 : _colorSchemesInput$li.palette
        })),
        {
          palette: lightPalette
        } = _createThemeWithoutVa,
        muiTheme = _objectWithoutPropertiesLoose$2(_createThemeWithoutVa, _excluded2);
      const {
        palette: darkPalette
      } = createTheme({
        palette: _extends$4({
          mode: 'dark'
        }, (_colorSchemesInput$da = colorSchemesInput.dark) == null ? void 0 : _colorSchemesInput$da.palette)
      });
      let theme = _extends$4({}, muiTheme, {
        cssVarPrefix,
        getCssVar,
        colorSchemes: _extends$4({}, colorSchemesInput, {
          light: _extends$4({}, colorSchemesInput.light, {
            palette: lightPalette,
            opacity: _extends$4({
              inputPlaceholder: 0.42,
              inputUnderline: 0.42,
              switchTrackDisabled: 0.12,
              switchTrack: 0.38
            }, (_colorSchemesInput$li2 = colorSchemesInput.light) == null ? void 0 : _colorSchemesInput$li2.opacity),
            overlays: ((_colorSchemesInput$li3 = colorSchemesInput.light) == null ? void 0 : _colorSchemesInput$li3.overlays) || []
          }),
          dark: _extends$4({}, colorSchemesInput.dark, {
            palette: darkPalette,
            opacity: _extends$4({
              inputPlaceholder: 0.5,
              inputUnderline: 0.7,
              switchTrackDisabled: 0.2,
              switchTrack: 0.3
            }, (_colorSchemesInput$da2 = colorSchemesInput.dark) == null ? void 0 : _colorSchemesInput$da2.opacity),
            overlays: ((_colorSchemesInput$da3 = colorSchemesInput.dark) == null ? void 0 : _colorSchemesInput$da3.overlays) || defaultDarkOverlays
          })
        })
      });
      Object.keys(theme.colorSchemes).forEach(key => {
        const palette = theme.colorSchemes[key].palette;
        const setCssVarColor = cssVar => {
          const tokens = cssVar.split('-');
          const color = tokens[1];
          const colorToken = tokens[2];
          return getCssVar(cssVar, palette[color][colorToken]);
        };

        // attach black & white channels to common node
        if (key === 'light') {
          setColor(palette.common, 'background', '#fff');
          setColor(palette.common, 'onBackground', '#000');
        } else {
          setColor(palette.common, 'background', '#000');
          setColor(palette.common, 'onBackground', '#fff');
        }

        // assign component variables
        assignNode(palette, ['Alert', 'AppBar', 'Avatar', 'Button', 'Chip', 'FilledInput', 'LinearProgress', 'Skeleton', 'Slider', 'SnackbarContent', 'SpeedDialAction', 'StepConnector', 'StepContent', 'Switch', 'TableCell', 'Tooltip']);
        if (key === 'light') {
          setColor(palette.Alert, 'errorColor', private_safeDarken(palette.error.light, 0.6));
          setColor(palette.Alert, 'infoColor', private_safeDarken(palette.info.light, 0.6));
          setColor(palette.Alert, 'successColor', private_safeDarken(palette.success.light, 0.6));
          setColor(palette.Alert, 'warningColor', private_safeDarken(palette.warning.light, 0.6));
          setColor(palette.Alert, 'errorFilledBg', setCssVarColor('palette-error-main'));
          setColor(palette.Alert, 'infoFilledBg', setCssVarColor('palette-info-main'));
          setColor(palette.Alert, 'successFilledBg', setCssVarColor('palette-success-main'));
          setColor(palette.Alert, 'warningFilledBg', setCssVarColor('palette-warning-main'));
          setColor(palette.Alert, 'errorFilledColor', silent(() => lightPalette.getContrastText(palette.error.main)));
          setColor(palette.Alert, 'infoFilledColor', silent(() => lightPalette.getContrastText(palette.info.main)));
          setColor(palette.Alert, 'successFilledColor', silent(() => lightPalette.getContrastText(palette.success.main)));
          setColor(palette.Alert, 'warningFilledColor', silent(() => lightPalette.getContrastText(palette.warning.main)));
          setColor(palette.Alert, 'errorStandardBg', private_safeLighten(palette.error.light, 0.9));
          setColor(palette.Alert, 'infoStandardBg', private_safeLighten(palette.info.light, 0.9));
          setColor(palette.Alert, 'successStandardBg', private_safeLighten(palette.success.light, 0.9));
          setColor(palette.Alert, 'warningStandardBg', private_safeLighten(palette.warning.light, 0.9));
          setColor(palette.Alert, 'errorIconColor', setCssVarColor('palette-error-main'));
          setColor(palette.Alert, 'infoIconColor', setCssVarColor('palette-info-main'));
          setColor(palette.Alert, 'successIconColor', setCssVarColor('palette-success-main'));
          setColor(palette.Alert, 'warningIconColor', setCssVarColor('palette-warning-main'));
          setColor(palette.AppBar, 'defaultBg', setCssVarColor('palette-grey-100'));
          setColor(palette.Avatar, 'defaultBg', setCssVarColor('palette-grey-400'));
          setColor(palette.Button, 'inheritContainedBg', setCssVarColor('palette-grey-300'));
          setColor(palette.Button, 'inheritContainedHoverBg', setCssVarColor('palette-grey-A100'));
          setColor(palette.Chip, 'defaultBorder', setCssVarColor('palette-grey-400'));
          setColor(palette.Chip, 'defaultAvatarColor', setCssVarColor('palette-grey-700'));
          setColor(palette.Chip, 'defaultIconColor', setCssVarColor('palette-grey-700'));
          setColor(palette.FilledInput, 'bg', 'rgba(0, 0, 0, 0.06)');
          setColor(palette.FilledInput, 'hoverBg', 'rgba(0, 0, 0, 0.09)');
          setColor(palette.FilledInput, 'disabledBg', 'rgba(0, 0, 0, 0.12)');
          setColor(palette.LinearProgress, 'primaryBg', private_safeLighten(palette.primary.main, 0.62));
          setColor(palette.LinearProgress, 'secondaryBg', private_safeLighten(palette.secondary.main, 0.62));
          setColor(palette.LinearProgress, 'errorBg', private_safeLighten(palette.error.main, 0.62));
          setColor(palette.LinearProgress, 'infoBg', private_safeLighten(palette.info.main, 0.62));
          setColor(palette.LinearProgress, 'successBg', private_safeLighten(palette.success.main, 0.62));
          setColor(palette.LinearProgress, 'warningBg', private_safeLighten(palette.warning.main, 0.62));
          setColor(palette.Skeleton, 'bg', `rgba(${setCssVarColor('palette-text-primaryChannel')} / 0.11)`);
          setColor(palette.Slider, 'primaryTrack', private_safeLighten(palette.primary.main, 0.62));
          setColor(palette.Slider, 'secondaryTrack', private_safeLighten(palette.secondary.main, 0.62));
          setColor(palette.Slider, 'errorTrack', private_safeLighten(palette.error.main, 0.62));
          setColor(palette.Slider, 'infoTrack', private_safeLighten(palette.info.main, 0.62));
          setColor(palette.Slider, 'successTrack', private_safeLighten(palette.success.main, 0.62));
          setColor(palette.Slider, 'warningTrack', private_safeLighten(palette.warning.main, 0.62));
          const snackbarContentBackground = private_safeEmphasize(palette.background.default, 0.8);
          setColor(palette.SnackbarContent, 'bg', snackbarContentBackground);
          setColor(palette.SnackbarContent, 'color', silent(() => lightPalette.getContrastText(snackbarContentBackground)));
          setColor(palette.SpeedDialAction, 'fabHoverBg', private_safeEmphasize(palette.background.paper, 0.15));
          setColor(palette.StepConnector, 'border', setCssVarColor('palette-grey-400'));
          setColor(palette.StepContent, 'border', setCssVarColor('palette-grey-400'));
          setColor(palette.Switch, 'defaultColor', setCssVarColor('palette-common-white'));
          setColor(palette.Switch, 'defaultDisabledColor', setCssVarColor('palette-grey-100'));
          setColor(palette.Switch, 'primaryDisabledColor', private_safeLighten(palette.primary.main, 0.62));
          setColor(palette.Switch, 'secondaryDisabledColor', private_safeLighten(palette.secondary.main, 0.62));
          setColor(palette.Switch, 'errorDisabledColor', private_safeLighten(palette.error.main, 0.62));
          setColor(palette.Switch, 'infoDisabledColor', private_safeLighten(palette.info.main, 0.62));
          setColor(palette.Switch, 'successDisabledColor', private_safeLighten(palette.success.main, 0.62));
          setColor(palette.Switch, 'warningDisabledColor', private_safeLighten(palette.warning.main, 0.62));
          setColor(palette.TableCell, 'border', private_safeLighten(private_safeAlpha(palette.divider, 1), 0.88));
          setColor(palette.Tooltip, 'bg', private_safeAlpha(palette.grey[700], 0.92));
        } else {
          setColor(palette.Alert, 'errorColor', private_safeLighten(palette.error.light, 0.6));
          setColor(palette.Alert, 'infoColor', private_safeLighten(palette.info.light, 0.6));
          setColor(palette.Alert, 'successColor', private_safeLighten(palette.success.light, 0.6));
          setColor(palette.Alert, 'warningColor', private_safeLighten(palette.warning.light, 0.6));
          setColor(palette.Alert, 'errorFilledBg', setCssVarColor('palette-error-dark'));
          setColor(palette.Alert, 'infoFilledBg', setCssVarColor('palette-info-dark'));
          setColor(palette.Alert, 'successFilledBg', setCssVarColor('palette-success-dark'));
          setColor(palette.Alert, 'warningFilledBg', setCssVarColor('palette-warning-dark'));
          setColor(palette.Alert, 'errorFilledColor', silent(() => darkPalette.getContrastText(palette.error.dark)));
          setColor(palette.Alert, 'infoFilledColor', silent(() => darkPalette.getContrastText(palette.info.dark)));
          setColor(palette.Alert, 'successFilledColor', silent(() => darkPalette.getContrastText(palette.success.dark)));
          setColor(palette.Alert, 'warningFilledColor', silent(() => darkPalette.getContrastText(palette.warning.dark)));
          setColor(palette.Alert, 'errorStandardBg', private_safeDarken(palette.error.light, 0.9));
          setColor(palette.Alert, 'infoStandardBg', private_safeDarken(palette.info.light, 0.9));
          setColor(palette.Alert, 'successStandardBg', private_safeDarken(palette.success.light, 0.9));
          setColor(palette.Alert, 'warningStandardBg', private_safeDarken(palette.warning.light, 0.9));
          setColor(palette.Alert, 'errorIconColor', setCssVarColor('palette-error-main'));
          setColor(palette.Alert, 'infoIconColor', setCssVarColor('palette-info-main'));
          setColor(palette.Alert, 'successIconColor', setCssVarColor('palette-success-main'));
          setColor(palette.Alert, 'warningIconColor', setCssVarColor('palette-warning-main'));
          setColor(palette.AppBar, 'defaultBg', setCssVarColor('palette-grey-900'));
          setColor(palette.AppBar, 'darkBg', setCssVarColor('palette-background-paper')); // specific for dark mode
          setColor(palette.AppBar, 'darkColor', setCssVarColor('palette-text-primary')); // specific for dark mode
          setColor(palette.Avatar, 'defaultBg', setCssVarColor('palette-grey-600'));
          setColor(palette.Button, 'inheritContainedBg', setCssVarColor('palette-grey-800'));
          setColor(palette.Button, 'inheritContainedHoverBg', setCssVarColor('palette-grey-700'));
          setColor(palette.Chip, 'defaultBorder', setCssVarColor('palette-grey-700'));
          setColor(palette.Chip, 'defaultAvatarColor', setCssVarColor('palette-grey-300'));
          setColor(palette.Chip, 'defaultIconColor', setCssVarColor('palette-grey-300'));
          setColor(palette.FilledInput, 'bg', 'rgba(255, 255, 255, 0.09)');
          setColor(palette.FilledInput, 'hoverBg', 'rgba(255, 255, 255, 0.13)');
          setColor(palette.FilledInput, 'disabledBg', 'rgba(255, 255, 255, 0.12)');
          setColor(palette.LinearProgress, 'primaryBg', private_safeDarken(palette.primary.main, 0.5));
          setColor(palette.LinearProgress, 'secondaryBg', private_safeDarken(palette.secondary.main, 0.5));
          setColor(palette.LinearProgress, 'errorBg', private_safeDarken(palette.error.main, 0.5));
          setColor(palette.LinearProgress, 'infoBg', private_safeDarken(palette.info.main, 0.5));
          setColor(palette.LinearProgress, 'successBg', private_safeDarken(palette.success.main, 0.5));
          setColor(palette.LinearProgress, 'warningBg', private_safeDarken(palette.warning.main, 0.5));
          setColor(palette.Skeleton, 'bg', `rgba(${setCssVarColor('palette-text-primaryChannel')} / 0.13)`);
          setColor(palette.Slider, 'primaryTrack', private_safeDarken(palette.primary.main, 0.5));
          setColor(palette.Slider, 'secondaryTrack', private_safeDarken(palette.secondary.main, 0.5));
          setColor(palette.Slider, 'errorTrack', private_safeDarken(palette.error.main, 0.5));
          setColor(palette.Slider, 'infoTrack', private_safeDarken(palette.info.main, 0.5));
          setColor(palette.Slider, 'successTrack', private_safeDarken(palette.success.main, 0.5));
          setColor(palette.Slider, 'warningTrack', private_safeDarken(palette.warning.main, 0.5));
          const snackbarContentBackground = private_safeEmphasize(palette.background.default, 0.98);
          setColor(palette.SnackbarContent, 'bg', snackbarContentBackground);
          setColor(palette.SnackbarContent, 'color', silent(() => darkPalette.getContrastText(snackbarContentBackground)));
          setColor(palette.SpeedDialAction, 'fabHoverBg', private_safeEmphasize(palette.background.paper, 0.15));
          setColor(palette.StepConnector, 'border', setCssVarColor('palette-grey-600'));
          setColor(palette.StepContent, 'border', setCssVarColor('palette-grey-600'));
          setColor(palette.Switch, 'defaultColor', setCssVarColor('palette-grey-300'));
          setColor(palette.Switch, 'defaultDisabledColor', setCssVarColor('palette-grey-600'));
          setColor(palette.Switch, 'primaryDisabledColor', private_safeDarken(palette.primary.main, 0.55));
          setColor(palette.Switch, 'secondaryDisabledColor', private_safeDarken(palette.secondary.main, 0.55));
          setColor(palette.Switch, 'errorDisabledColor', private_safeDarken(palette.error.main, 0.55));
          setColor(palette.Switch, 'infoDisabledColor', private_safeDarken(palette.info.main, 0.55));
          setColor(palette.Switch, 'successDisabledColor', private_safeDarken(palette.success.main, 0.55));
          setColor(palette.Switch, 'warningDisabledColor', private_safeDarken(palette.warning.main, 0.55));
          setColor(palette.TableCell, 'border', private_safeDarken(private_safeAlpha(palette.divider, 1), 0.68));
          setColor(palette.Tooltip, 'bg', private_safeAlpha(palette.grey[700], 0.92));
        }

        // MUI X - DataGrid needs this token.
        setColorChannel(palette.background, 'default');
        setColorChannel(palette.common, 'background');
        setColorChannel(palette.common, 'onBackground');
        setColorChannel(palette, 'divider');
        Object.keys(palette).forEach(color => {
          const colors = palette[color];

          // The default palettes (primary, secondary, error, info, success, and warning) errors are handled by the above `createTheme(...)`.

          if (colors && typeof colors === 'object') {
            // Silent the error for custom palettes.
            if (colors.main) {
              setColor(palette[color], 'mainChannel', private_safeColorChannel(colors.main));
            }
            if (colors.light) {
              setColor(palette[color], 'lightChannel', private_safeColorChannel(colors.light));
            }
            if (colors.dark) {
              setColor(palette[color], 'darkChannel', private_safeColorChannel(colors.dark));
            }
            if (colors.contrastText) {
              setColor(palette[color], 'contrastTextChannel', private_safeColorChannel(colors.contrastText));
            }
            if (color === 'text') {
              // Text colors: text.primary, text.secondary
              setColorChannel(palette[color], 'primary');
              setColorChannel(palette[color], 'secondary');
            }
            if (color === 'action') {
              // Action colors: action.active, action.selected
              if (colors.active) {
                setColorChannel(palette[color], 'active');
              }
              if (colors.selected) {
                setColorChannel(palette[color], 'selected');
              }
            }
          }
        });
      });
      theme = args.reduce((acc, argument) => deepmerge(acc, argument), theme);
      const parserConfig = {
        prefix: cssVarPrefix,
        shouldSkipGeneratingVar: shouldSkipGeneratingVar$1
      };
      const {
        vars: themeVars,
        generateCssVars
      } = prepareCssVars(theme, parserConfig);
      theme.vars = themeVars;
      theme.generateCssVars = generateCssVars;
      theme.shouldSkipGeneratingVar = shouldSkipGeneratingVar$1;
      theme.unstable_sxConfig = _extends$4({}, defaultSxConfig$1, input == null ? void 0 : input.unstable_sxConfig);
      theme.unstable_sx = function sx(props) {
        return styleFunctionSx$1({
          sx: props,
          theme: this
        });
      };
      return theme;
    }

    /**
     * @internal These variables should not appear in the :root stylesheet when the `defaultMode="dark"`
     */
    const excludeVariablesFromRoot = cssVarPrefix => [...[...Array(24)].map((_, index) => `--${cssVarPrefix ? `${cssVarPrefix}-` : ''}overlays-${index + 1}`), `--${cssVarPrefix ? `${cssVarPrefix}-` : ''}palette-AppBar-darkBg`, `--${cssVarPrefix ? `${cssVarPrefix}-` : ''}palette-AppBar-darkColor`];

    const defaultTheme$1 = extendTheme();
    createCssVarsProvider({
      themeId: THEME_ID,
      theme: defaultTheme$1,
      attribute: 'data-mui-color-scheme',
      modeStorageKey: 'mui-mode',
      colorSchemeStorageKey: 'mui-color-scheme',
      defaultColorScheme: {
        light: 'light',
        dark: 'dark'
      },
      resolveTheme: theme => {
        const newTheme = _extends$4({}, theme, {
          typography: createTypography(theme.palette, theme.typography)
        });
        newTheme.unstable_sx = function sx(props) {
          return styleFunctionSx$1({
            sx: props,
            theme: this
          });
        };
        return newTheme;
      },
      excludeVariablesFromRoot
    });

    function r$3(e){var t,f,n="";if("string"==typeof e||"number"==typeof e)n+=e;else if("object"==typeof e)if(Array.isArray(e))for(t=0;t<e.length;t++)e[t]&&(f=r$3(e[t]))&&(n&&(n+=" "),n+=f);else for(t in e)e[t]&&(n&&(n+=" "),n+=t);return n}function clsx$1(){for(var e,t,f=0,n="";f<arguments.length;)(e=arguments[f++])&&(t=r$3(e))&&(n&&(n+=" "),n+=t);return n}

    function _extends() {
      _extends = Object.assign ? Object.assign.bind() : function (target) {
        for (var i = 1; i < arguments.length; i++) {
          var source = arguments[i];
          for (var key in source) {
            if (Object.prototype.hasOwnProperty.call(source, key)) {
              target[key] = source[key];
            }
          }
        }
        return target;
      };
      return _extends.apply(this, arguments);
    }

    /**
     * Determines if a given element is a DOM element name (i.e. not a React component).
     */
    function isHostComponent(element) {
      return typeof element === 'string';
    }

    function _objectWithoutPropertiesLoose(source, excluded) {
      if (source == null) return {};
      var target = {};
      var sourceKeys = Object.keys(source);
      var key, i;
      for (i = 0; i < sourceKeys.length; i++) {
        key = sourceKeys[i];
        if (excluded.indexOf(key) >= 0) continue;
        target[key] = source[key];
      }
      return target;
    }

    /**
     * NoSsr purposely removes components from the subject of Server Side Rendering (SSR).
     *
     * This component can be useful in a variety of situations:
     *
     * *   Escape hatch for broken dependencies not supporting SSR.
     * *   Improve the time-to-first paint on the client by only rendering above the fold.
     * *   Reduce the rendering time on the server.
     * *   Under too heavy server load, you can turn on service degradation.
     *
     * Demos:
     *
     * - [No SSR](https://mui.com/base-ui/react-no-ssr/)
     *
     * API:
     *
     * - [NoSsr API](https://mui.com/base-ui/react-no-ssr/components-api/#no-ssr)
     */
    function NoSsr(props) {
      const {
        children,
        defer = false,
        fallback = null
      } = props;
      const [mountedState, setMountedState] = reactExports.useState(false);
      useEnhancedEffect$1(() => {
        if (!defer) {
          setMountedState(true);
        }
      }, [defer]);
      reactExports.useEffect(() => {
        if (defer) {
          setMountedState(true);
        }
      }, [defer]);

      // We need the Fragment here to force react-docgen to recognise NoSsr as a component.
      return /*#__PURE__*/jsxRuntimeExports.jsx(reactExports.Fragment, {
        children: mountedState ? children : fallback
      });
    }

    const _excluded$3 = ["onChange", "maxRows", "minRows", "style", "value"];
    function getStyleValue(value) {
      return parseInt(value, 10) || 0;
    }
    const styles = {
      shadow: {
        // Visibility needed to hide the extra text area on iPads
        visibility: 'hidden',
        // Remove from the content flow
        position: 'absolute',
        // Ignore the scrollbar width
        overflow: 'hidden',
        height: 0,
        top: 0,
        left: 0,
        // Create a new layer, increase the isolation of the computed values
        transform: 'translateZ(0)'
      }
    };
    function isEmpty(obj) {
      return obj === undefined || obj === null || Object.keys(obj).length === 0 || obj.outerHeightStyle === 0 && !obj.overflow;
    }

    /**
     *
     * Demos:
     *
     * - [Textarea Autosize](https://mui.com/base-ui/react-textarea-autosize/)
     * - [Textarea Autosize](https://mui.com/material-ui/react-textarea-autosize/)
     *
     * API:
     *
     * - [TextareaAutosize API](https://mui.com/base-ui/react-textarea-autosize/components-api/#textarea-autosize)
     */
    const TextareaAutosize = /*#__PURE__*/reactExports.forwardRef(function TextareaAutosize(props, forwardedRef) {
      const {
          onChange,
          maxRows,
          minRows = 1,
          style,
          value
        } = props,
        other = _objectWithoutPropertiesLoose(props, _excluded$3);
      const {
        current: isControlled
      } = reactExports.useRef(value != null);
      const inputRef = reactExports.useRef(null);
      const handleRef = useForkRef(forwardedRef, inputRef);
      const shadowRef = reactExports.useRef(null);
      const renders = reactExports.useRef(0);
      const [state, setState] = reactExports.useState({
        outerHeightStyle: 0
      });
      const getUpdatedState = reactExports.useCallback(() => {
        const input = inputRef.current;
        const containerWindow = ownerWindow(input);
        const computedStyle = containerWindow.getComputedStyle(input);

        // If input's width is shrunk and it's not visible, don't sync height.
        if (computedStyle.width === '0px') {
          return {
            outerHeightStyle: 0
          };
        }
        const inputShallow = shadowRef.current;
        inputShallow.style.width = computedStyle.width;
        inputShallow.value = input.value || props.placeholder || 'x';
        if (inputShallow.value.slice(-1) === '\n') {
          // Certain fonts which overflow the line height will cause the textarea
          // to report a different scrollHeight depending on whether the last line
          // is empty. Make it non-empty to avoid this issue.
          inputShallow.value += ' ';
        }
        const boxSizing = computedStyle.boxSizing;
        const padding = getStyleValue(computedStyle.paddingBottom) + getStyleValue(computedStyle.paddingTop);
        const border = getStyleValue(computedStyle.borderBottomWidth) + getStyleValue(computedStyle.borderTopWidth);

        // The height of the inner content
        const innerHeight = inputShallow.scrollHeight;

        // Measure height of a textarea with a single row
        inputShallow.value = 'x';
        const singleRowHeight = inputShallow.scrollHeight;

        // The height of the outer content
        let outerHeight = innerHeight;
        if (minRows) {
          outerHeight = Math.max(Number(minRows) * singleRowHeight, outerHeight);
        }
        if (maxRows) {
          outerHeight = Math.min(Number(maxRows) * singleRowHeight, outerHeight);
        }
        outerHeight = Math.max(outerHeight, singleRowHeight);

        // Take the box sizing into account for applying this value as a style.
        const outerHeightStyle = outerHeight + (boxSizing === 'border-box' ? padding + border : 0);
        const overflow = Math.abs(outerHeight - innerHeight) <= 1;
        return {
          outerHeightStyle,
          overflow
        };
      }, [maxRows, minRows, props.placeholder]);
      const updateState = (prevState, newState) => {
        const {
          outerHeightStyle,
          overflow
        } = newState;
        // Need a large enough difference to update the height.
        // This prevents infinite rendering loop.
        if (renders.current < 20 && (outerHeightStyle > 0 && Math.abs((prevState.outerHeightStyle || 0) - outerHeightStyle) > 1 || prevState.overflow !== overflow)) {
          renders.current += 1;
          return {
            overflow,
            outerHeightStyle
          };
        }
        return prevState;
      };
      const syncHeight = reactExports.useCallback(() => {
        const newState = getUpdatedState();
        if (isEmpty(newState)) {
          return;
        }
        setState(prevState => {
          return updateState(prevState, newState);
        });
      }, [getUpdatedState]);
      const syncHeightWithFlushSync = () => {
        const newState = getUpdatedState();
        if (isEmpty(newState)) {
          return;
        }

        // In React 18, state updates in a ResizeObserver's callback are happening after the paint which causes flickering
        // when doing some visual updates in it. Using flushSync ensures that the dom will be painted after the states updates happen
        // Related issue - https://github.com/facebook/react/issues/24331
        reactDomExports.flushSync(() => {
          setState(prevState => {
            return updateState(prevState, newState);
          });
        });
      };
      reactExports.useEffect(() => {
        const handleResize = debounce(() => {
          renders.current = 0;

          // If the TextareaAutosize component is replaced by Suspense with a fallback, the last
          // ResizeObserver's handler that runs because of the change in the layout is trying to
          // access a dom node that is no longer there (as the fallback component is being shown instead).
          // See https://github.com/mui/material-ui/issues/32640
          if (inputRef.current) {
            syncHeightWithFlushSync();
          }
        });
        let resizeObserver;
        const input = inputRef.current;
        const containerWindow = ownerWindow(input);
        containerWindow.addEventListener('resize', handleResize);
        if (typeof ResizeObserver !== 'undefined') {
          resizeObserver = new ResizeObserver(handleResize);
          resizeObserver.observe(input);
        }
        return () => {
          handleResize.clear();
          containerWindow.removeEventListener('resize', handleResize);
          if (resizeObserver) {
            resizeObserver.disconnect();
          }
        };
      });
      useEnhancedEffect$1(() => {
        syncHeight();
      });
      reactExports.useEffect(() => {
        renders.current = 0;
      }, [value]);
      const handleChange = event => {
        renders.current = 0;
        if (!isControlled) {
          syncHeight();
        }
        if (onChange) {
          onChange(event);
        }
      };
      return /*#__PURE__*/jsxRuntimeExports.jsxs(reactExports.Fragment, {
        children: [/*#__PURE__*/jsxRuntimeExports.jsx("textarea", _extends({
          value: value,
          onChange: handleChange,
          ref: handleRef
          // Apply the rows prop to get a "correct" first SSR paint
          ,
          rows: minRows,
          style: _extends({
            height: state.outerHeightStyle,
            // Need a large enough difference to allow scrolling.
            // This prevents infinite rendering loop.
            overflow: state.overflow ? 'hidden' : undefined
          }, style)
        }, other)), /*#__PURE__*/jsxRuntimeExports.jsx("textarea", {
          "aria-hidden": true,
          className: props.className,
          readOnly: true,
          ref: shadowRef,
          tabIndex: -1,
          style: _extends({}, styles.shadow, style, {
            paddingTop: 0,
            paddingBottom: 0
          })
        })]
      });
    });
    var TextareaAutosize$1 = TextareaAutosize;

    function getSvgIconUtilityClass(slot) {
      return generateUtilityClass('MuiSvgIcon', slot);
    }
    generateUtilityClasses('MuiSvgIcon', ['root', 'colorPrimary', 'colorSecondary', 'colorAction', 'colorError', 'colorDisabled', 'fontSizeInherit', 'fontSizeSmall', 'fontSizeMedium', 'fontSizeLarge']);

    const _excluded$2 = ["children", "className", "color", "component", "fontSize", "htmlColor", "inheritViewBox", "titleAccess", "viewBox"];
    const useUtilityClasses$2 = ownerState => {
      const {
        color,
        fontSize,
        classes
      } = ownerState;
      const slots = {
        root: ['root', color !== 'inherit' && `color${capitalize(color)}`, `fontSize${capitalize(fontSize)}`]
      };
      return composeClasses(slots, getSvgIconUtilityClass, classes);
    };
    const SvgIconRoot = styled('svg', {
      name: 'MuiSvgIcon',
      slot: 'Root',
      overridesResolver: (props, styles) => {
        const {
          ownerState
        } = props;
        return [styles.root, ownerState.color !== 'inherit' && styles[`color${capitalize(ownerState.color)}`], styles[`fontSize${capitalize(ownerState.fontSize)}`]];
      }
    })(({
      theme,
      ownerState
    }) => {
      var _theme$transitions, _theme$transitions$cr, _theme$transitions2, _theme$typography, _theme$typography$pxT, _theme$typography2, _theme$typography2$px, _theme$typography3, _theme$typography3$px, _palette$ownerState$c, _palette, _palette2, _palette3;
      return {
        userSelect: 'none',
        width: '1em',
        height: '1em',
        display: 'inline-block',
        // the <svg> will define the property that has `currentColor`
        // e.g. heroicons uses fill="none" and stroke="currentColor"
        fill: ownerState.hasSvgAsChild ? undefined : 'currentColor',
        flexShrink: 0,
        transition: (_theme$transitions = theme.transitions) == null || (_theme$transitions$cr = _theme$transitions.create) == null ? void 0 : _theme$transitions$cr.call(_theme$transitions, 'fill', {
          duration: (_theme$transitions2 = theme.transitions) == null || (_theme$transitions2 = _theme$transitions2.duration) == null ? void 0 : _theme$transitions2.shorter
        }),
        fontSize: {
          inherit: 'inherit',
          small: ((_theme$typography = theme.typography) == null || (_theme$typography$pxT = _theme$typography.pxToRem) == null ? void 0 : _theme$typography$pxT.call(_theme$typography, 20)) || '1.25rem',
          medium: ((_theme$typography2 = theme.typography) == null || (_theme$typography2$px = _theme$typography2.pxToRem) == null ? void 0 : _theme$typography2$px.call(_theme$typography2, 24)) || '1.5rem',
          large: ((_theme$typography3 = theme.typography) == null || (_theme$typography3$px = _theme$typography3.pxToRem) == null ? void 0 : _theme$typography3$px.call(_theme$typography3, 35)) || '2.1875rem'
        }[ownerState.fontSize],
        // TODO v5 deprecate, v6 remove for sx
        color: (_palette$ownerState$c = (_palette = (theme.vars || theme).palette) == null || (_palette = _palette[ownerState.color]) == null ? void 0 : _palette.main) != null ? _palette$ownerState$c : {
          action: (_palette2 = (theme.vars || theme).palette) == null || (_palette2 = _palette2.action) == null ? void 0 : _palette2.active,
          disabled: (_palette3 = (theme.vars || theme).palette) == null || (_palette3 = _palette3.action) == null ? void 0 : _palette3.disabled,
          inherit: undefined
        }[ownerState.color]
      };
    });
    const SvgIcon = /*#__PURE__*/reactExports.forwardRef(function SvgIcon(inProps, ref) {
      const props = useThemeProps({
        props: inProps,
        name: 'MuiSvgIcon'
      });
      const {
          children,
          className,
          color = 'inherit',
          component = 'svg',
          fontSize = 'medium',
          htmlColor,
          inheritViewBox = false,
          titleAccess,
          viewBox = '0 0 24 24'
        } = props,
        other = _objectWithoutPropertiesLoose$2(props, _excluded$2);
      const hasSvgAsChild = /*#__PURE__*/reactExports.isValidElement(children) && children.type === 'svg';
      const ownerState = _extends$4({}, props, {
        color,
        component,
        fontSize,
        instanceFontSize: inProps.fontSize,
        inheritViewBox,
        viewBox,
        hasSvgAsChild
      });
      const more = {};
      if (!inheritViewBox) {
        more.viewBox = viewBox;
      }
      const classes = useUtilityClasses$2(ownerState);
      return /*#__PURE__*/jsxRuntimeExports.jsxs(SvgIconRoot, _extends$4({
        as: component,
        className: clsx$1(classes.root, className),
        focusable: "false",
        color: htmlColor,
        "aria-hidden": titleAccess ? undefined : true,
        role: titleAccess ? 'img' : undefined,
        ref: ref
      }, more, other, hasSvgAsChild && children.props, {
        ownerState: ownerState,
        children: [hasSvgAsChild ? children.props.children : children, titleAccess ? /*#__PURE__*/jsxRuntimeExports.jsx("title", {
          children: titleAccess
        }) : null]
      }));
    });
    SvgIcon.muiName = 'SvgIcon';
    var SvgIcon$1 = SvgIcon;

    function getPaperUtilityClass(slot) {
      return generateUtilityClass('MuiPaper', slot);
    }
    generateUtilityClasses('MuiPaper', ['root', 'rounded', 'outlined', 'elevation', 'elevation0', 'elevation1', 'elevation2', 'elevation3', 'elevation4', 'elevation5', 'elevation6', 'elevation7', 'elevation8', 'elevation9', 'elevation10', 'elevation11', 'elevation12', 'elevation13', 'elevation14', 'elevation15', 'elevation16', 'elevation17', 'elevation18', 'elevation19', 'elevation20', 'elevation21', 'elevation22', 'elevation23', 'elevation24']);

    const _excluded$1 = ["className", "component", "elevation", "square", "variant"];
    const useUtilityClasses$1 = ownerState => {
      const {
        square,
        elevation,
        variant,
        classes
      } = ownerState;
      const slots = {
        root: ['root', variant, !square && 'rounded', variant === 'elevation' && `elevation${elevation}`]
      };
      return composeClasses(slots, getPaperUtilityClass, classes);
    };
    const PaperRoot = styled('div', {
      name: 'MuiPaper',
      slot: 'Root',
      overridesResolver: (props, styles) => {
        const {
          ownerState
        } = props;
        return [styles.root, styles[ownerState.variant], !ownerState.square && styles.rounded, ownerState.variant === 'elevation' && styles[`elevation${ownerState.elevation}`]];
      }
    })(({
      theme,
      ownerState
    }) => {
      var _theme$vars$overlays;
      return _extends$4({
        backgroundColor: (theme.vars || theme).palette.background.paper,
        color: (theme.vars || theme).palette.text.primary,
        transition: theme.transitions.create('box-shadow')
      }, !ownerState.square && {
        borderRadius: theme.shape.borderRadius
      }, ownerState.variant === 'outlined' && {
        border: `1px solid ${(theme.vars || theme).palette.divider}`
      }, ownerState.variant === 'elevation' && _extends$4({
        boxShadow: (theme.vars || theme).shadows[ownerState.elevation]
      }, !theme.vars && theme.palette.mode === 'dark' && {
        backgroundImage: `linear-gradient(${alpha('#fff', getOverlayAlpha(ownerState.elevation))}, ${alpha('#fff', getOverlayAlpha(ownerState.elevation))})`
      }, theme.vars && {
        backgroundImage: (_theme$vars$overlays = theme.vars.overlays) == null ? void 0 : _theme$vars$overlays[ownerState.elevation]
      }));
    });
    const Paper = /*#__PURE__*/reactExports.forwardRef(function Paper(inProps, ref) {
      const props = useThemeProps({
        props: inProps,
        name: 'MuiPaper'
      });
      const {
          className,
          component = 'div',
          elevation = 1,
          square = false,
          variant = 'elevation'
        } = props,
        other = _objectWithoutPropertiesLoose$2(props, _excluded$1);
      const ownerState = _extends$4({}, props, {
        component,
        elevation,
        square,
        variant
      });
      const classes = useUtilityClasses$1(ownerState);
      return /*#__PURE__*/jsxRuntimeExports.jsx(PaperRoot, _extends$4({
        as: component,
        ownerState: ownerState,
        className: clsx$1(classes.root, className),
        ref: ref
      }, other));
    });
    var Paper$1 = Paper;

    function formControlState({
      props,
      states,
      muiFormControl
    }) {
      return states.reduce((acc, state) => {
        acc[state] = props[state];
        if (muiFormControl) {
          if (typeof props[state] === 'undefined') {
            acc[state] = muiFormControl[state];
          }
        }
        return acc;
      }, {});
    }

    /**
     * @ignore - internal component.
     */
    const FormControlContext = /*#__PURE__*/reactExports.createContext(undefined);

    function useFormControl() {
      return reactExports.useContext(FormControlContext);
    }

    function GlobalStyles(props) {
      return /*#__PURE__*/jsxRuntimeExports.jsx(GlobalStyles$1, _extends$4({}, props, {
        defaultTheme: defaultTheme$2,
        themeId: THEME_ID
      }));
    }

    // Supports determination of isControlled().
    // Controlled input accepts its current value as a prop.
    //
    // @see https://facebook.github.io/react/docs/forms.html#controlled-components
    // @param value
    // @returns {boolean} true if string (including '') or number (including zero)
    function hasValue(value) {
      return value != null && !(Array.isArray(value) && value.length === 0);
    }

    // Determine if field is empty or filled.
    // Response determines if label is presented above field or as placeholder.
    //
    // @param obj
    // @param SSR
    // @returns {boolean} False when not present or empty string.
    //                    True when any number or string with length.
    function isFilled(obj, SSR = false) {
      return obj && (hasValue(obj.value) && obj.value !== '' || SSR && hasValue(obj.defaultValue) && obj.defaultValue !== '');
    }

    function getInputBaseUtilityClass(slot) {
      return generateUtilityClass('MuiInputBase', slot);
    }
    const inputBaseClasses = generateUtilityClasses('MuiInputBase', ['root', 'formControl', 'focused', 'disabled', 'adornedStart', 'adornedEnd', 'error', 'sizeSmall', 'multiline', 'colorSecondary', 'fullWidth', 'hiddenLabel', 'readOnly', 'input', 'inputSizeSmall', 'inputMultiline', 'inputTypeSearch', 'inputAdornedStart', 'inputAdornedEnd', 'inputHiddenLabel']);

    const _excluded = ["aria-describedby", "autoComplete", "autoFocus", "className", "color", "components", "componentsProps", "defaultValue", "disabled", "disableInjectingGlobalStyles", "endAdornment", "error", "fullWidth", "id", "inputComponent", "inputProps", "inputRef", "margin", "maxRows", "minRows", "multiline", "name", "onBlur", "onChange", "onClick", "onFocus", "onKeyDown", "onKeyUp", "placeholder", "readOnly", "renderSuffix", "rows", "size", "slotProps", "slots", "startAdornment", "type", "value"];
    const rootOverridesResolver = (props, styles) => {
      const {
        ownerState
      } = props;
      return [styles.root, ownerState.formControl && styles.formControl, ownerState.startAdornment && styles.adornedStart, ownerState.endAdornment && styles.adornedEnd, ownerState.error && styles.error, ownerState.size === 'small' && styles.sizeSmall, ownerState.multiline && styles.multiline, ownerState.color && styles[`color${capitalize(ownerState.color)}`], ownerState.fullWidth && styles.fullWidth, ownerState.hiddenLabel && styles.hiddenLabel];
    };
    const inputOverridesResolver = (props, styles) => {
      const {
        ownerState
      } = props;
      return [styles.input, ownerState.size === 'small' && styles.inputSizeSmall, ownerState.multiline && styles.inputMultiline, ownerState.type === 'search' && styles.inputTypeSearch, ownerState.startAdornment && styles.inputAdornedStart, ownerState.endAdornment && styles.inputAdornedEnd, ownerState.hiddenLabel && styles.inputHiddenLabel];
    };
    const useUtilityClasses = ownerState => {
      const {
        classes,
        color,
        disabled,
        error,
        endAdornment,
        focused,
        formControl,
        fullWidth,
        hiddenLabel,
        multiline,
        readOnly,
        size,
        startAdornment,
        type
      } = ownerState;
      const slots = {
        root: ['root', `color${capitalize(color)}`, disabled && 'disabled', error && 'error', fullWidth && 'fullWidth', focused && 'focused', formControl && 'formControl', size === 'small' && 'sizeSmall', multiline && 'multiline', startAdornment && 'adornedStart', endAdornment && 'adornedEnd', hiddenLabel && 'hiddenLabel', readOnly && 'readOnly'],
        input: ['input', disabled && 'disabled', type === 'search' && 'inputTypeSearch', multiline && 'inputMultiline', size === 'small' && 'inputSizeSmall', hiddenLabel && 'inputHiddenLabel', startAdornment && 'inputAdornedStart', endAdornment && 'inputAdornedEnd', readOnly && 'readOnly']
      };
      return composeClasses(slots, getInputBaseUtilityClass, classes);
    };
    const InputBaseRoot = styled('div', {
      name: 'MuiInputBase',
      slot: 'Root',
      overridesResolver: rootOverridesResolver
    })(({
      theme,
      ownerState
    }) => _extends$4({}, theme.typography.body1, {
      color: (theme.vars || theme).palette.text.primary,
      lineHeight: '1.4375em',
      // 23px
      boxSizing: 'border-box',
      // Prevent padding issue with fullWidth.
      position: 'relative',
      cursor: 'text',
      display: 'inline-flex',
      alignItems: 'center',
      [`&.${inputBaseClasses.disabled}`]: {
        color: (theme.vars || theme).palette.text.disabled,
        cursor: 'default'
      }
    }, ownerState.multiline && _extends$4({
      padding: '4px 0 5px'
    }, ownerState.size === 'small' && {
      paddingTop: 1
    }), ownerState.fullWidth && {
      width: '100%'
    }));
    const InputBaseComponent = styled('input', {
      name: 'MuiInputBase',
      slot: 'Input',
      overridesResolver: inputOverridesResolver
    })(({
      theme,
      ownerState
    }) => {
      const light = theme.palette.mode === 'light';
      const placeholder = _extends$4({
        color: 'currentColor'
      }, theme.vars ? {
        opacity: theme.vars.opacity.inputPlaceholder
      } : {
        opacity: light ? 0.42 : 0.5
      }, {
        transition: theme.transitions.create('opacity', {
          duration: theme.transitions.duration.shorter
        })
      });
      const placeholderHidden = {
        opacity: '0 !important'
      };
      const placeholderVisible = theme.vars ? {
        opacity: theme.vars.opacity.inputPlaceholder
      } : {
        opacity: light ? 0.42 : 0.5
      };
      return _extends$4({
        font: 'inherit',
        letterSpacing: 'inherit',
        color: 'currentColor',
        padding: '4px 0 5px',
        border: 0,
        boxSizing: 'content-box',
        background: 'none',
        height: '1.4375em',
        // Reset 23pxthe native input line-height
        margin: 0,
        // Reset for Safari
        WebkitTapHighlightColor: 'transparent',
        display: 'block',
        // Make the flex item shrink with Firefox
        minWidth: 0,
        width: '100%',
        // Fix IE11 width issue
        animationName: 'mui-auto-fill-cancel',
        animationDuration: '10ms',
        '&::-webkit-input-placeholder': placeholder,
        '&::-moz-placeholder': placeholder,
        // Firefox 19+
        '&:-ms-input-placeholder': placeholder,
        // IE11
        '&::-ms-input-placeholder': placeholder,
        // Edge
        '&:focus': {
          outline: 0
        },
        // Reset Firefox invalid required input style
        '&:invalid': {
          boxShadow: 'none'
        },
        '&::-webkit-search-decoration': {
          // Remove the padding when type=search.
          WebkitAppearance: 'none'
        },
        // Show and hide the placeholder logic
        [`label[data-shrink=false] + .${inputBaseClasses.formControl} &`]: {
          '&::-webkit-input-placeholder': placeholderHidden,
          '&::-moz-placeholder': placeholderHidden,
          // Firefox 19+
          '&:-ms-input-placeholder': placeholderHidden,
          // IE11
          '&::-ms-input-placeholder': placeholderHidden,
          // Edge
          '&:focus::-webkit-input-placeholder': placeholderVisible,
          '&:focus::-moz-placeholder': placeholderVisible,
          // Firefox 19+
          '&:focus:-ms-input-placeholder': placeholderVisible,
          // IE11
          '&:focus::-ms-input-placeholder': placeholderVisible // Edge
        },

        [`&.${inputBaseClasses.disabled}`]: {
          opacity: 1,
          // Reset iOS opacity
          WebkitTextFillColor: (theme.vars || theme).palette.text.disabled // Fix opacity Safari bug
        },

        '&:-webkit-autofill': {
          animationDuration: '5000s',
          animationName: 'mui-auto-fill'
        }
      }, ownerState.size === 'small' && {
        paddingTop: 1
      }, ownerState.multiline && {
        height: 'auto',
        resize: 'none',
        padding: 0,
        paddingTop: 0
      }, ownerState.type === 'search' && {
        // Improve type search style.
        MozAppearance: 'textfield'
      });
    });
    const inputGlobalStyles = /*#__PURE__*/jsxRuntimeExports.jsx(GlobalStyles, {
      styles: {
        '@keyframes mui-auto-fill': {
          from: {
            display: 'block'
          }
        },
        '@keyframes mui-auto-fill-cancel': {
          from: {
            display: 'block'
          }
        }
      }
    });

    /**
     * `InputBase` contains as few styles as possible.
     * It aims to be a simple building block for creating an input.
     * It contains a load of style reset and some state logic.
     */
    const InputBase = /*#__PURE__*/reactExports.forwardRef(function InputBase(inProps, ref) {
      var _slotProps$input;
      const props = useThemeProps({
        props: inProps,
        name: 'MuiInputBase'
      });
      const {
          'aria-describedby': ariaDescribedby,
          autoComplete,
          autoFocus,
          className,
          components = {},
          componentsProps = {},
          defaultValue,
          disabled,
          disableInjectingGlobalStyles,
          endAdornment,
          fullWidth = false,
          id,
          inputComponent = 'input',
          inputProps: inputPropsProp = {},
          inputRef: inputRefProp,
          maxRows,
          minRows,
          multiline = false,
          name,
          onBlur,
          onChange,
          onClick,
          onFocus,
          onKeyDown,
          onKeyUp,
          placeholder,
          readOnly,
          renderSuffix,
          rows,
          slotProps = {},
          slots = {},
          startAdornment,
          type = 'text',
          value: valueProp
        } = props,
        other = _objectWithoutPropertiesLoose$2(props, _excluded);
      const value = inputPropsProp.value != null ? inputPropsProp.value : valueProp;
      const {
        current: isControlled
      } = reactExports.useRef(value != null);
      const inputRef = reactExports.useRef();
      const handleInputRefWarning = reactExports.useCallback(instance => {
      }, []);
      const handleInputRef = useForkRef(inputRef, inputRefProp, inputPropsProp.ref, handleInputRefWarning);
      const [focused, setFocused] = reactExports.useState(false);
      const muiFormControl = useFormControl();
      const fcs = formControlState({
        props,
        muiFormControl,
        states: ['color', 'disabled', 'error', 'hiddenLabel', 'size', 'required', 'filled']
      });
      fcs.focused = muiFormControl ? muiFormControl.focused : focused;

      // The blur won't fire when the disabled state is set on a focused input.
      // We need to book keep the focused state manually.
      reactExports.useEffect(() => {
        if (!muiFormControl && disabled && focused) {
          setFocused(false);
          if (onBlur) {
            onBlur();
          }
        }
      }, [muiFormControl, disabled, focused, onBlur]);
      const onFilled = muiFormControl && muiFormControl.onFilled;
      const onEmpty = muiFormControl && muiFormControl.onEmpty;
      const checkDirty = reactExports.useCallback(obj => {
        if (isFilled(obj)) {
          if (onFilled) {
            onFilled();
          }
        } else if (onEmpty) {
          onEmpty();
        }
      }, [onFilled, onEmpty]);
      useEnhancedEffect$1(() => {
        if (isControlled) {
          checkDirty({
            value
          });
        }
      }, [value, checkDirty, isControlled]);
      const handleFocus = event => {
        // Fix a bug with IE11 where the focus/blur events are triggered
        // while the component is disabled.
        if (fcs.disabled) {
          event.stopPropagation();
          return;
        }
        if (onFocus) {
          onFocus(event);
        }
        if (inputPropsProp.onFocus) {
          inputPropsProp.onFocus(event);
        }
        if (muiFormControl && muiFormControl.onFocus) {
          muiFormControl.onFocus(event);
        } else {
          setFocused(true);
        }
      };
      const handleBlur = event => {
        if (onBlur) {
          onBlur(event);
        }
        if (inputPropsProp.onBlur) {
          inputPropsProp.onBlur(event);
        }
        if (muiFormControl && muiFormControl.onBlur) {
          muiFormControl.onBlur(event);
        } else {
          setFocused(false);
        }
      };
      const handleChange = (event, ...args) => {
        if (!isControlled) {
          const element = event.target || inputRef.current;
          if (element == null) {
            throw new Error(formatMuiErrorMessage(1));
          }
          checkDirty({
            value: element.value
          });
        }
        if (inputPropsProp.onChange) {
          inputPropsProp.onChange(event, ...args);
        }

        // Perform in the willUpdate
        if (onChange) {
          onChange(event, ...args);
        }
      };

      // Check the input state on mount, in case it was filled by the user
      // or auto filled by the browser before the hydration (for SSR).
      reactExports.useEffect(() => {
        checkDirty(inputRef.current);
        // eslint-disable-next-line react-hooks/exhaustive-deps
      }, []);
      const handleClick = event => {
        if (inputRef.current && event.currentTarget === event.target) {
          inputRef.current.focus();
        }
        if (onClick && !fcs.disabled) {
          onClick(event);
        }
      };
      let InputComponent = inputComponent;
      let inputProps = inputPropsProp;
      if (multiline && InputComponent === 'input') {
        if (rows) {
          inputProps = _extends$4({
            type: undefined,
            minRows: rows,
            maxRows: rows
          }, inputProps);
        } else {
          inputProps = _extends$4({
            type: undefined,
            maxRows,
            minRows
          }, inputProps);
        }
        InputComponent = TextareaAutosize$1;
      }
      const handleAutoFill = event => {
        // Provide a fake value as Chrome might not let you access it for security reasons.
        checkDirty(event.animationName === 'mui-auto-fill-cancel' ? inputRef.current : {
          value: 'x'
        });
      };
      reactExports.useEffect(() => {
        if (muiFormControl) {
          muiFormControl.setAdornedStart(Boolean(startAdornment));
        }
      }, [muiFormControl, startAdornment]);
      const ownerState = _extends$4({}, props, {
        color: fcs.color || 'primary',
        disabled: fcs.disabled,
        endAdornment,
        error: fcs.error,
        focused: fcs.focused,
        formControl: muiFormControl,
        fullWidth,
        hiddenLabel: fcs.hiddenLabel,
        multiline,
        size: fcs.size,
        startAdornment,
        type
      });
      const classes = useUtilityClasses(ownerState);
      const Root = slots.root || components.Root || InputBaseRoot;
      const rootProps = slotProps.root || componentsProps.root || {};
      const Input = slots.input || components.Input || InputBaseComponent;
      inputProps = _extends$4({}, inputProps, (_slotProps$input = slotProps.input) != null ? _slotProps$input : componentsProps.input);
      return /*#__PURE__*/jsxRuntimeExports.jsxs(reactExports.Fragment, {
        children: [!disableInjectingGlobalStyles && inputGlobalStyles, /*#__PURE__*/jsxRuntimeExports.jsxs(Root, _extends$4({}, rootProps, !isHostComponent(Root) && {
          ownerState: _extends$4({}, ownerState, rootProps.ownerState)
        }, {
          ref: ref,
          onClick: handleClick
        }, other, {
          className: clsx$1(classes.root, rootProps.className, className, readOnly && 'MuiInputBase-readOnly'),
          children: [startAdornment, /*#__PURE__*/jsxRuntimeExports.jsx(FormControlContext.Provider, {
            value: null,
            children: /*#__PURE__*/jsxRuntimeExports.jsx(Input, _extends$4({
              ownerState: ownerState,
              "aria-invalid": fcs.error,
              "aria-describedby": ariaDescribedby,
              autoComplete: autoComplete,
              autoFocus: autoFocus,
              defaultValue: defaultValue,
              disabled: fcs.disabled,
              id: id,
              onAnimationStart: handleAutoFill,
              name: name,
              placeholder: placeholder,
              readOnly: readOnly,
              required: fcs.required,
              rows: rows,
              value: value,
              onKeyDown: onKeyDown,
              onKeyUp: onKeyUp,
              type: type
            }, inputProps, !isHostComponent(Input) && {
              as: InputComponent,
              ownerState: _extends$4({}, ownerState, inputProps.ownerState)
            }, {
              ref: handleInputRef,
              className: clsx$1(classes.input, inputProps.className, readOnly && 'MuiInputBase-readOnly'),
              onBlur: handleBlur,
              onChange: handleChange,
              onFocus: handleFocus
            }))
          }), endAdornment, renderSuffix ? renderSuffix(_extends$4({}, fcs, {
            startAdornment
          })) : null]
        }))]
      });
    });
    var InputBase$1 = InputBase;

    const defaultTheme = createTheme();
    const Box = createBox({
      themeId: THEME_ID,
      defaultTheme,
      defaultClassName: 'MuiBox-root',
      generateClassName: ClassNameGenerator$1.generate
    });
    var Box$1 = Box;

    function r$2(e){var t,f,n="";if("string"==typeof e||"number"==typeof e)n+=e;else if("object"==typeof e)if(Array.isArray(e))for(t=0;t<e.length;t++)e[t]&&(f=r$2(e[t]))&&(n&&(n+=" "),n+=f);else for(t in e)e[t]&&(n&&(n+=" "),n+=t);return n}function clsx(){for(var e,t,f=0,n="";f<arguments.length;)(e=arguments[f++])&&(t=r$2(e))&&(n&&(n+=" "),n+=t);return n}

    const createStoreImpl = (createState) => {
      let state;
      const listeners = /* @__PURE__ */ new Set();
      const setState = (partial, replace) => {
        const nextState = typeof partial === "function" ? partial(state) : partial;
        if (!Object.is(nextState, state)) {
          const previousState = state;
          state = (replace != null ? replace : typeof nextState !== "object" || nextState === null) ? nextState : Object.assign({}, state, nextState);
          listeners.forEach((listener) => listener(state, previousState));
        }
      };
      const getState = () => state;
      const subscribe = (listener) => {
        listeners.add(listener);
        return () => listeners.delete(listener);
      };
      const destroy = () => {
        if ((undefined ? undefined.MODE : void 0) !== "production") {
          console.warn(
            "[DEPRECATED] The `destroy` method will be unsupported in a future version. Instead use unsubscribe function returned by subscribe. Everything will be garbage-collected if store is garbage-collected."
          );
        }
        listeners.clear();
      };
      const api = { setState, getState, subscribe, destroy };
      state = createState(setState, getState, api);
      return api;
    };
    const createStore = (createState) => createState ? createStoreImpl(createState) : createStoreImpl;

    var withSelector = {exports: {}};

    var withSelector_production_min = {};

    var shim = {exports: {}};

    var useSyncExternalStoreShim_production_min = {};

    /**
     * @license React
     * use-sync-external-store-shim.production.min.js
     *
     * Copyright (c) Facebook, Inc. and its affiliates.
     *
     * This source code is licensed under the MIT license found in the
     * LICENSE file in the root directory of this source tree.
     */
    var e=reactExports;function h$1(a,b){return a===b&&(0!==a||1/a===1/b)||a!==a&&b!==b}var k="function"===typeof Object.is?Object.is:h$1,l=e.useState,m=e.useEffect,n$1=e.useLayoutEffect,p$1=e.useDebugValue;function q$1(a,b){var d=b(),f=l({inst:{value:d,getSnapshot:b}}),c=f[0].inst,g=f[1];n$1(function(){c.value=d;c.getSnapshot=b;r$1(c)&&g({inst:c});},[a,d,b]);m(function(){r$1(c)&&g({inst:c});return a(function(){r$1(c)&&g({inst:c});})},[a]);p$1(d);return d}
    function r$1(a){var b=a.getSnapshot;a=a.value;try{var d=b();return !k(a,d)}catch(f){return !0}}function t$1(a,b){return b()}var u$1="undefined"===typeof window.document||"undefined"===typeof window.document.createElement?t$1:q$1;useSyncExternalStoreShim_production_min.useSyncExternalStore=void 0!==e.useSyncExternalStore?e.useSyncExternalStore:u$1;

    {
      shim.exports = useSyncExternalStoreShim_production_min;
    }

    var shimExports = shim.exports;

    /**
     * @license React
     * use-sync-external-store-shim/with-selector.production.min.js
     *
     * Copyright (c) Facebook, Inc. and its affiliates.
     *
     * This source code is licensed under the MIT license found in the
     * LICENSE file in the root directory of this source tree.
     */
    var h=reactExports,n=shimExports;function p(a,b){return a===b&&(0!==a||1/a===1/b)||a!==a&&b!==b}var q="function"===typeof Object.is?Object.is:p,r=n.useSyncExternalStore,t=h.useRef,u=h.useEffect,v=h.useMemo,w=h.useDebugValue;
    withSelector_production_min.useSyncExternalStoreWithSelector=function(a,b,e,l,g){var c=t(null);if(null===c.current){var f={hasValue:!1,value:null};c.current=f;}else f=c.current;c=v(function(){function a(a){if(!c){c=!0;d=a;a=l(a);if(void 0!==g&&f.hasValue){var b=f.value;if(g(b,a))return k=b}return k=a}b=k;if(q(d,a))return b;var e=l(a);if(void 0!==g&&g(b,e))return b;d=a;return k=e}var c=!1,d,k,m=void 0===e?null:e;return [function(){return a(b())},null===m?void 0:function(){return a(m())}]},[b,e,l,g]);var d=r(a,c[0],c[1]);
    u(function(){f.hasValue=!0;f.value=d;},[d]);w(d);return d};

    {
      withSelector.exports = withSelector_production_min;
    }

    var withSelectorExports = withSelector.exports;
    var useSyncExternalStoreExports = /*@__PURE__*/getDefaultExportFromCjs(withSelectorExports);

    const { useDebugValue } = ReactExports;
    const { useSyncExternalStoreWithSelector } = useSyncExternalStoreExports;
    let didWarnAboutEqualityFn = false;
    function useStore(api, selector = api.getState, equalityFn) {
      if ((undefined ? undefined.MODE : void 0) !== "production" && equalityFn && !didWarnAboutEqualityFn) {
        console.warn(
          "[DEPRECATED] Use `createWithEqualityFn` instead of `create` or use `useStoreWithEqualityFn` instead of `useStore`. They can be imported from 'zustand/traditional'. https://github.com/pmndrs/zustand/discussions/1937"
        );
        didWarnAboutEqualityFn = true;
      }
      const slice = useSyncExternalStoreWithSelector(
        api.subscribe,
        api.getState,
        api.getServerState || api.getState,
        selector,
        equalityFn
      );
      useDebugValue(slice);
      return slice;
    }
    const createImpl = (createState) => {
      if ((undefined ? undefined.MODE : void 0) !== "production" && typeof createState !== "function") {
        console.warn(
          "[DEPRECATED] Passing a vanilla store will be unsupported in a future version. Instead use `import { useStore } from 'zustand'`."
        );
      }
      const api = typeof createState === "function" ? createStore(createState) : createState;
      const useBoundStore = (selector, equalityFn) => useStore(api, selector, equalityFn);
      Object.assign(useBoundStore, api);
      return useBoundStore;
    };
    const create = (createState) => createState ? createImpl(createState) : createImpl;

    const lightColorspace = {
        scheme: "Light Theme",
        author: "mac gainor (https://github.com/mac-s-g)",
        base00: "rgba(0, 0, 0, 0)",
        base01: "rgb(245, 245, 245)",
        base02: "rgb(235, 235, 235)",
        base03: "#93a1a1",
        base04: "rgba(0, 0, 0, 0.3)",
        base05: "#586e75",
        base06: "#073642",
        base07: "#002b36",
        base08: "#d33682",
        base09: "#cb4b16",
        base0A: "#ffd500",
        base0B: "#859900",
        base0C: "#6c71c4",
        base0D: "#586e75",
        base0E: "#2aa198",
        base0F: "#268bd2"
    };
    const darkColorspace = {
        scheme: "Dark Theme",
        author: "Chris Kempson (http://chriskempson.com)",
        base00: "#181818",
        base01: "#282828",
        base02: "#383838",
        base03: "#585858",
        base04: "#b8b8b8",
        base05: "#d8d8d8",
        base06: "#e8e8e8",
        base07: "#f8f8f8",
        base08: "#ab4642",
        base09: "#dc9656",
        base0A: "#f7ca88",
        base0B: "#a1b56c",
        base0C: "#86c1b9",
        base0D: "#7cafc2",
        base0E: "#ba8baf",
        base0F: "#a16946"
    };

    var base16 = /*#__PURE__*/Object.freeze({
        __proto__: null,
        darkColorspace: darkColorspace,
        lightColorspace: lightColorspace
    });

    const DefaultKeyRenderer = ()=>null;
    DefaultKeyRenderer.when = ()=>false;
    const createJsonViewerStore = (props)=>{
        var _props_rootName, _props_indentWidth, _props_keyRenderer, _props_enableAdd, _props_enableDelete, _props_enableClipboard, _props_editable, _props_onChange, _props_onCopy, _props_onSelect, _props_onAdd, _props_onDelete, _props_defaultInspectDepth, _props_defaultInspectControl, _props_maxDisplayLength, _props_groupArraysAfterLength, _props_collapseStringsAfterLength, _props_objectSortKeys, _props_quotesOnKeys, _props_displayDataTypes, _props_displaySize, _props_highlightUpdates;
        return create()((set, get)=>({
                // provided by user
                rootName: (_props_rootName = props.rootName) !== null && _props_rootName !== void 0 ? _props_rootName : "root",
                indentWidth: (_props_indentWidth = props.indentWidth) !== null && _props_indentWidth !== void 0 ? _props_indentWidth : 3,
                keyRenderer: (_props_keyRenderer = props.keyRenderer) !== null && _props_keyRenderer !== void 0 ? _props_keyRenderer : DefaultKeyRenderer,
                enableAdd: (_props_enableAdd = props.enableAdd) !== null && _props_enableAdd !== void 0 ? _props_enableAdd : false,
                enableDelete: (_props_enableDelete = props.enableDelete) !== null && _props_enableDelete !== void 0 ? _props_enableDelete : false,
                enableClipboard: (_props_enableClipboard = props.enableClipboard) !== null && _props_enableClipboard !== void 0 ? _props_enableClipboard : true,
                editable: (_props_editable = props.editable) !== null && _props_editable !== void 0 ? _props_editable : false,
                onChange: (_props_onChange = props.onChange) !== null && _props_onChange !== void 0 ? _props_onChange : ()=>{},
                onCopy: (_props_onCopy = props.onCopy) !== null && _props_onCopy !== void 0 ? _props_onCopy : undefined,
                onSelect: (_props_onSelect = props.onSelect) !== null && _props_onSelect !== void 0 ? _props_onSelect : undefined,
                onAdd: (_props_onAdd = props.onAdd) !== null && _props_onAdd !== void 0 ? _props_onAdd : undefined,
                onDelete: (_props_onDelete = props.onDelete) !== null && _props_onDelete !== void 0 ? _props_onDelete : undefined,
                defaultInspectDepth: (_props_defaultInspectDepth = props.defaultInspectDepth) !== null && _props_defaultInspectDepth !== void 0 ? _props_defaultInspectDepth : 5,
                defaultInspectControl: (_props_defaultInspectControl = props.defaultInspectControl) !== null && _props_defaultInspectControl !== void 0 ? _props_defaultInspectControl : undefined,
                maxDisplayLength: (_props_maxDisplayLength = props.maxDisplayLength) !== null && _props_maxDisplayLength !== void 0 ? _props_maxDisplayLength : 30,
                groupArraysAfterLength: (_props_groupArraysAfterLength = props.groupArraysAfterLength) !== null && _props_groupArraysAfterLength !== void 0 ? _props_groupArraysAfterLength : 100,
                collapseStringsAfterLength: props.collapseStringsAfterLength === false ? Number.MAX_VALUE : (_props_collapseStringsAfterLength = props.collapseStringsAfterLength) !== null && _props_collapseStringsAfterLength !== void 0 ? _props_collapseStringsAfterLength : 50,
                objectSortKeys: (_props_objectSortKeys = props.objectSortKeys) !== null && _props_objectSortKeys !== void 0 ? _props_objectSortKeys : false,
                quotesOnKeys: (_props_quotesOnKeys = props.quotesOnKeys) !== null && _props_quotesOnKeys !== void 0 ? _props_quotesOnKeys : true,
                displayDataTypes: (_props_displayDataTypes = props.displayDataTypes) !== null && _props_displayDataTypes !== void 0 ? _props_displayDataTypes : true,
                displaySize: (_props_displaySize = props.displaySize) !== null && _props_displaySize !== void 0 ? _props_displaySize : true,
                highlightUpdates: (_props_highlightUpdates = props.highlightUpdates) !== null && _props_highlightUpdates !== void 0 ? _props_highlightUpdates : false,
                // internal state
                inspectCache: {},
                hoverPath: null,
                colorspace: lightColorspace,
                value: props.value,
                prevValue: undefined,
                getInspectCache: (path, nestedIndex)=>{
                    const target = nestedIndex !== undefined ? path.join(".") + "[".concat(nestedIndex, "]nt") : path.join(".");
                    return get().inspectCache[target];
                },
                setInspectCache: (path, action, nestedIndex)=>{
                    const target = nestedIndex !== undefined ? path.join(".") + "[".concat(nestedIndex, "]nt") : path.join(".");
                    set((state)=>({
                            inspectCache: {
                                ...state.inspectCache,
                                [target]: typeof action === "function" ? action(state.inspectCache[target]) : action
                            }
                        }));
                },
                setHover: (path, nestedIndex)=>{
                    set({
                        hoverPath: path ? {
                            path,
                            nestedIndex
                        } : null
                    });
                }
            }));
    };
    // @ts-expect-error we intentionally want to pass undefined to the context
    // See https://github.com/DefinitelyTyped/DefinitelyTyped/pull/24509#issuecomment-382213106
    const JsonViewerStoreContext = reactExports.createContext(undefined);
    JsonViewerStoreContext.Provider;
    const useJsonViewerStore = (selector, equalityFn)=>{
        const store = reactExports.useContext(JsonViewerStoreContext);
        return useStore(store, selector, equalityFn);
    };

    const useTextColor = ()=>{
        return useJsonViewerStore((store)=>store.colorspace.base07);
    };

    var toggleSelection = function () {
      var selection = document.getSelection();
      if (!selection.rangeCount) {
        return function () {};
      }
      var active = document.activeElement;

      var ranges = [];
      for (var i = 0; i < selection.rangeCount; i++) {
        ranges.push(selection.getRangeAt(i));
      }

      switch (active.tagName.toUpperCase()) { // .toUpperCase handles XHTML
        case 'INPUT':
        case 'TEXTAREA':
          active.blur();
          break;

        default:
          active = null;
          break;
      }

      selection.removeAllRanges();
      return function () {
        selection.type === 'Caret' &&
        selection.removeAllRanges();

        if (!selection.rangeCount) {
          ranges.forEach(function(range) {
            selection.addRange(range);
          });
        }

        active &&
        active.focus();
      };
    };

    var deselectCurrent = toggleSelection;

    var clipboardToIE11Formatting = {
      "text/plain": "Text",
      "text/html": "Url",
      "default": "Text"
    };

    var defaultMessage = "Copy to clipboard: #{key}, Enter";

    function format(message) {
      var copyKey = (/mac os x/i.test(navigator.userAgent) ? "⌘" : "Ctrl") + "+C";
      return message.replace(/#{\s*key\s*}/g, copyKey);
    }

    function copy(text, options) {
      var debug,
        message,
        reselectPrevious,
        range,
        selection,
        mark,
        success = false;
      if (!options) {
        options = {};
      }
      debug = options.debug || false;
      try {
        reselectPrevious = deselectCurrent();

        range = document.createRange();
        selection = document.getSelection();

        mark = document.createElement("span");
        mark.textContent = text;
        // avoid screen readers from reading out loud the text
        mark.ariaHidden = "true";
        // reset user styles for span element
        mark.style.all = "unset";
        // prevents scrolling to the end of the page
        mark.style.position = "fixed";
        mark.style.top = 0;
        mark.style.clip = "rect(0, 0, 0, 0)";
        // used to preserve spaces and line breaks
        mark.style.whiteSpace = "pre";
        // do not inherit user-select (it may be `none`)
        mark.style.webkitUserSelect = "text";
        mark.style.MozUserSelect = "text";
        mark.style.msUserSelect = "text";
        mark.style.userSelect = "text";
        mark.addEventListener("copy", function(e) {
          e.stopPropagation();
          if (options.format) {
            e.preventDefault();
            if (typeof e.clipboardData === "undefined") { // IE 11
              debug && console.warn("unable to use e.clipboardData");
              debug && console.warn("trying IE specific stuff");
              window.clipboardData.clearData();
              var format = clipboardToIE11Formatting[options.format] || clipboardToIE11Formatting["default"];
              window.clipboardData.setData(format, text);
            } else { // all other browsers
              e.clipboardData.clearData();
              e.clipboardData.setData(options.format, text);
            }
          }
          if (options.onCopy) {
            e.preventDefault();
            options.onCopy(e.clipboardData);
          }
        });

        document.body.appendChild(mark);

        range.selectNodeContents(mark);
        selection.addRange(range);

        var successful = document.execCommand("copy");
        if (!successful) {
          throw new Error("copy command was unsuccessful");
        }
        success = true;
      } catch (err) {
        debug && console.error("unable to copy using execCommand: ", err);
        debug && console.warn("trying IE specific stuff");
        try {
          window.clipboardData.setData(options.format || "text", text);
          options.onCopy && options.onCopy(window.clipboardData);
          success = true;
        } catch (err) {
          debug && console.error("unable to copy using clipboardData: ", err);
          debug && console.error("falling back to prompt");
          message = format("message" in options ? options.message : defaultMessage);
          window.prompt(message, text);
        }
      } finally {
        if (selection) {
          if (typeof selection.removeRange == "function") {
            selection.removeRange(range);
          } else {
            selection.removeAllRanges();
          }
        }

        if (mark) {
          document.body.removeChild(mark);
        }
        reselectPrevious();
      }

      return success;
    }

    var copyToClipboard = copy;

    var copyToClipboard$1 = /*@__PURE__*/getDefaultExportFromCjs(copyToClipboard);

    // reference: https://github.com/immerjs/immer/blob/main/src/utils/common.ts
    const objectCtorString = Object.prototype.constructor.toString();
    function isPlainObject(value) {
        if (!value || typeof value !== "object") return false;
        const proto = Object.getPrototypeOf(value);
        if (proto === null) return true;
        const Ctor = Object.hasOwnProperty.call(proto, "constructor") && proto.constructor;
        if (Ctor === Object) return true;
        return typeof Ctor === "function" && Function.toString.call(Ctor) === objectCtorString;
    }
    function shouldShallowCopy(value) {
        if (!value) return false;
        return isPlainObject(value) || Array.isArray(value) || value instanceof Map || value instanceof Set;
    }
    function shallowCopy(value) {
        if (Array.isArray(value)) return Array.prototype.slice.call(value);
        if (value instanceof Set) return new Set(value);
        if (value instanceof Map) return new Map(value);
        if (typeof value === "object" && value !== null) {
            return Object.assign({}, value);
        }
        return value;
    }
    /**
     * Apply a value to a given path of an object.
     */ function applyValue(input, path, value) {
        if (typeof input !== "object" || input === null) {
            if (path.length !== 0) {
                throw new Error("path is incorrect");
            }
            return value;
        }
        const shouldCopy = shouldShallowCopy(input);
        if (shouldCopy) input = shallowCopy(input);
        const [key, ...restPath] = path;
        if (key !== undefined) {
            if (key === "__proto__") {
                throw new TypeError("Modification of prototype is not allowed");
            }
            if (restPath.length > 0) {
                input[key] = applyValue(input[key], restPath, value);
            } else {
                input[key] = value;
            }
        }
        return input;
    }
    /**
     * Delete a value from a given path of an object.
     */ function deleteValue(input, path, value) {
        if (typeof input !== "object" || input === null) {
            if (path.length !== 0) {
                throw new Error("path is incorrect");
            }
            return value;
        }
        const shouldCopy = shouldShallowCopy(input);
        if (shouldCopy) input = shallowCopy(input);
        const [key, ...restPath] = path;
        if (key !== undefined) {
            if (key === "__proto__") {
                throw new TypeError("Modification of prototype is not allowed");
            }
            if (restPath.length > 0) {
                input[key] = deleteValue(input[key], restPath, value);
            } else {
                if (Array.isArray(input)) {
                    input.splice(Number(key), 1);
                } else {
                    delete input[key];
                }
            }
        }
        return input;
    }
    /**
     * Define custom data types for any data structure
     */ function defineDataType(param) {
        let { is, serialize, deserialize, Component, Editor, PreComponent, PostComponent } = param;
        return {
            is,
            serialize,
            deserialize,
            Component,
            Editor,
            PreComponent,
            PostComponent
        };
    }
    const isCycleReference = (root, path, value)=>{
        if (root === null || value === null) {
            return false;
        }
        if (typeof root !== "object") {
            return false;
        }
        if (typeof value !== "object") {
            return false;
        }
        if (Object.is(root, value) && path.length !== 0) {
            return "";
        }
        const currentPath = [];
        const arr = [
            ...path
        ];
        let currentRoot = root;
        while(currentRoot !== value || arr.length !== 0){
            if (typeof currentRoot !== "object" || currentRoot === null) {
                return false;
            }
            if (Object.is(currentRoot, value)) {
                return currentPath.reduce((path, value, currentIndex)=>{
                    if (typeof value === "number") {
                        return path + "[".concat(value, "]");
                    }
                    return path + "".concat(currentIndex === 0 ? "" : ".").concat(value);
                }, "");
            }
            const target = arr.shift();
            currentPath.push(target);
            currentRoot = currentRoot[target];
        }
        return false;
    };
    function getValueSize(value) {
        if (value === null || undefined) {
            return 0;
        } else if (Array.isArray(value)) {
            return value.length;
        } else if (value instanceof Map || value instanceof Set) {
            return value.size;
        } else if (value instanceof Date) {
            return 1;
        } else if (typeof value === "object") {
            return Object.keys(value).length;
        } else if (typeof value === "string") {
            return value.length;
        }
        return 1;
    }
    function segmentArray(arr, size) {
        const result = [];
        let index = 0;
        while(index < arr.length){
            result.push(arr.slice(index, index + size));
            index += size;
        }
        return result;
    }
    /**
     * A safe version of `JSON.stringify` that handles circular references and BigInts.
     *
     * *This function might be changed in the future to support more types. Use it with caution.*
     *
     * @param obj A JavaScript value, usually an object or array, to be converted.
     * @param space Adds indentation, white space, and line break characters to the return-value JSON text to make it easier to read.
     * @returns
     */ function safeStringify(obj, space) {
        const seenValues = [];
        function replacer(key, value) {
            // https://github.com/GoogleChromeLabs/jsbi/issues/30
            if (typeof value === "bigint") return value.toString();
            // Map and Set are not supported by JSON.stringify
            if (value instanceof Map) {
                if ("toJSON" in value && typeof value.toJSON === "function") return value.toJSON();
                if (value.size === 0) return {};
                if (seenValues.includes(value)) return "[Circular]";
                seenValues.push(value);
                const entries = Array.from(value.entries());
                if (entries.every((param)=>{
                    let [key] = param;
                    return typeof key === "string" || typeof key === "number";
                })) {
                    return Object.fromEntries(entries);
                }
                // if keys are not string or number, we can't convert to object
                // fallback to default behavior
                return {};
            }
            if (value instanceof Set) {
                if ("toJSON" in value && typeof value.toJSON === "function") return value.toJSON();
                if (seenValues.includes(value)) return "[Circular]";
                seenValues.push(value);
                return Array.from(value.values());
            }
            // https://stackoverflow.com/a/72457899
            if (typeof value === "object" && value !== null && Object.keys(value).length) {
                const stackSize = seenValues.length;
                if (stackSize) {
                    // clean up expired references
                    for(let n = stackSize - 1; n >= 0 && seenValues[n][key] !== value; --n){
                        seenValues.pop();
                    }
                    if (seenValues.includes(value)) return "[Circular]";
                }
                seenValues.push(value);
            }
            return value;
        }
        return JSON.stringify(obj, replacer, space);
    }
    async function copyString(value) {
        if ("clipboard" in navigator) {
            try {
                await navigator.clipboard.writeText(value);
            } catch  {
            // When navigator.clipboard throws an error, fallback to copy-to-clipboard package
            }
        }
        // fallback to copy-to-clipboard when navigator.clipboard is not available
        copyToClipboard$1(value);
    }

    /**
     * useClipboard hook accepts one argument options in which copied status timeout duration is defined (defaults to 2000). Hook returns object with properties:
     * - copy – function to copy value to clipboard
     * - copied – value that indicates that copy handler was called less than options.timeout ms ago
     * - reset – function to clear timeout and reset copied to false
     */ function useClipboard() {
        let { timeout = 2000 } = arguments.length > 0 && arguments[0] !== void 0 ? arguments[0] : {};
        const [copied, setCopied] = reactExports.useState(false);
        const copyTimeout = reactExports.useRef(null);
        const handleCopyResult = reactExports.useCallback((value)=>{
            const current = copyTimeout.current;
            if (current) {
                window.clearTimeout(current);
            }
            copyTimeout.current = window.setTimeout(()=>setCopied(false), timeout);
            setCopied(value);
        }, [
            timeout
        ]);
        const onCopy = useJsonViewerStore((store)=>store.onCopy);
        const copy = reactExports.useCallback(async (path, value)=>{
            if (typeof onCopy === "function") {
                try {
                    await onCopy(path, value, copyString);
                    handleCopyResult(true);
                } catch (error) {
                    console.error("error when copy ".concat(path.length === 0 ? "src" : "src[".concat(path.join(".")), "]"), error);
                }
            } else {
                try {
                    const valueToCopy = safeStringify(typeof value === "function" ? value.toString() : value, "  ");
                    await copyString(valueToCopy);
                    handleCopyResult(true);
                } catch (error) {
                    console.error("error when copy ".concat(path.length === 0 ? "src" : "src[".concat(path.join(".")), "]"), error);
                }
            }
        }, [
            handleCopyResult,
            onCopy
        ]);
        const reset = reactExports.useCallback(()=>{
            setCopied(false);
            if (copyTimeout.current) {
                clearTimeout(copyTimeout.current);
            }
        }, []);
        return {
            copy,
            reset,
            copied
        };
    }

    function useIsCycleReference(path, value) {
        const rootValue = useJsonViewerStore((store)=>store.value);
        return reactExports.useMemo(()=>isCycleReference(rootValue, path, value), [
            path,
            value,
            rootValue
        ]);
    }

    function useInspect(path, value, nestedIndex) {
        const depth = path.length;
        const isTrap = useIsCycleReference(path, value);
        const getInspectCache = useJsonViewerStore((store)=>store.getInspectCache);
        const setInspectCache = useJsonViewerStore((store)=>store.setInspectCache);
        const defaultInspectDepth = useJsonViewerStore((store)=>store.defaultInspectDepth);
        const defaultInspectControl = useJsonViewerStore((store)=>store.defaultInspectControl);
        reactExports.useEffect(()=>{
            const inspect = getInspectCache(path, nestedIndex);
            if (inspect !== undefined) {
                return;
            }
            // item with nestedIndex should not be inspected
            if (nestedIndex !== undefined) {
                setInspectCache(path, false, nestedIndex);
                return;
            }
            // do not inspect when it is a cycle reference, otherwise there will have a loop
            const shouldInspect = isTrap ? false : typeof defaultInspectControl === "function" ? defaultInspectControl(path, value) : depth < defaultInspectDepth;
            setInspectCache(path, shouldInspect);
        }, [
            defaultInspectDepth,
            defaultInspectControl,
            depth,
            getInspectCache,
            isTrap,
            nestedIndex,
            path,
            value,
            setInspectCache
        ]);
        const [inspect, set] = reactExports.useState(()=>{
            const shouldInspect = getInspectCache(path, nestedIndex);
            if (shouldInspect !== undefined) {
                return shouldInspect;
            }
            if (nestedIndex !== undefined) {
                return false;
            }
            return isTrap ? false : typeof defaultInspectControl === "function" ? defaultInspectControl(path, value) : depth < defaultInspectDepth;
        });
        const setInspect = reactExports.useCallback((apply)=>{
            set((oldState)=>{
                const newState = typeof apply === "boolean" ? apply : apply(oldState);
                setInspectCache(path, newState, nestedIndex);
                return newState;
            });
        }, [
            nestedIndex,
            path,
            setInspectCache
        ]);
        return [
            inspect,
            setInspect
        ];
    }

    const DataBox = (props)=>/*#__PURE__*/ jsxRuntimeExports.jsx(Box$1, {
            component: "div",
            ...props,
            sx: {
                display: "inline-block",
                ...props.sx
            }
        });

    const DataTypeLabel = (param)=>{
        let { dataType, enable = true } = param;
        if (!enable) return null;
        return /*#__PURE__*/ jsxRuntimeExports.jsx(DataBox, {
            className: "data-type-label",
            sx: {
                mx: 0.5,
                fontSize: "0.7rem",
                opacity: 0.8,
                userSelect: "none"
            },
            children: dataType
        });
    };

    /**
     * Enhanced version of `defineDataType` that creates a `DataType` with editor and a optional type label.
     * It will take care of the color and all the necessary props.
     *
     * *All of the built-in data types are defined with this function.*
     *
     * @param config.type The type name.
     * @param config.colorKey The color key in the colorspace. ('base00' - 'base0F')
     * @param config.displayTypeLabel Whether to display the type label.
     * @param config.Renderer The component to render the value.
     */ function defineEasyType(param) {
        let { is, serialize, deserialize, type, colorKey, displayTypeLabel = true, Renderer } = param;
        const Render = /*#__PURE__*/ reactExports.memo(Renderer);
        const EasyType = (props)=>{
            const storeDisplayDataTypes = useJsonViewerStore((store)=>store.displayDataTypes);
            const color = useJsonViewerStore((store)=>store.colorspace[colorKey]);
            const onSelect = useJsonViewerStore((store)=>store.onSelect);
            return /*#__PURE__*/ jsxRuntimeExports.jsxs(DataBox, {
                onClick: ()=>{
                    var _onSelect;
                    return (_onSelect = onSelect) === null || _onSelect === void 0 ? void 0 : _onSelect(props.path, props.value);
                },
                sx: {
                    color
                },
                children: [
                    displayTypeLabel && storeDisplayDataTypes && /*#__PURE__*/ jsxRuntimeExports.jsx(DataTypeLabel, {
                        dataType: type
                    }),
                    /*#__PURE__*/ jsxRuntimeExports.jsx(DataBox, {
                        className: "".concat(type, "-value"),
                        children: /*#__PURE__*/ jsxRuntimeExports.jsx(Render, {
                            path: props.path,
                            inspect: props.inspect,
                            setInspect: props.setInspect,
                            value: props.value,
                            prevValue: props.prevValue
                        })
                    })
                ]
            });
        };
        EasyType.displayName = "easy-".concat(type, "-type");
        if (!serialize || !deserialize) {
            return {
                is,
                Component: EasyType
            };
        }
        const EasyTypeEditor = (param)=>{
            let { value, setValue, abortEditing, commitEditing } = param;
            const color = useJsonViewerStore((store)=>store.colorspace[colorKey]);
            const handleKeyDown = reactExports.useCallback((event)=>{
                if (event.key === "Enter") {
                    event.preventDefault();
                    commitEditing(value);
                }
                if (event.key === "Escape") {
                    event.preventDefault();
                    abortEditing();
                }
            }, [
                abortEditing,
                commitEditing,
                value
            ]);
            const handleChange = reactExports.useCallback((event)=>{
                setValue(event.target.value);
            }, [
                setValue
            ]);
            return /*#__PURE__*/ jsxRuntimeExports.jsx(InputBase$1, {
                autoFocus: true,
                value: value,
                onChange: handleChange,
                onKeyDown: handleKeyDown,
                size: "small",
                multiline: true,
                sx: {
                    color,
                    padding: 0.5,
                    borderStyle: "solid",
                    borderColor: "black",
                    borderWidth: 1,
                    fontSize: "0.8rem",
                    fontFamily: "monospace",
                    display: "inline-flex"
                }
            });
        };
        EasyTypeEditor.displayName = "easy-".concat(type, "-type-editor");
        return {
            is,
            serialize,
            deserialize,
            Component: EasyType,
            Editor: EasyTypeEditor
        };
    }

    const booleanType = defineEasyType({
        is: (value)=>typeof value === "boolean",
        type: "bool",
        colorKey: "base0E",
        serialize: (value)=>value.toString(),
        deserialize: (value)=>{
            if (value === "true") return true;
            if (value === "false") return false;
            throw new Error("Invalid boolean value");
        },
        Renderer: (param)=> {
            let { value } = param;
            return jsxRuntimeExports.jsx(jsxRuntimeExports.Fragment, {
                children: value ? "true" : "false"
            });
        }
    });

    const displayOptions = {
        weekday: "short",
        year: "numeric",
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit"
    };
    const dateType = defineEasyType({
        is: (value)=>value instanceof Date,
        type: "date",
        colorKey: "base0D",
        Renderer: (param)=> {
            let { value } = param;
            return jsxRuntimeExports.jsx(jsxRuntimeExports.Fragment, {
                children: value.toLocaleTimeString("en-us", displayOptions)
            });
        }
    });

    const functionBody = (func)=>{
        const funcString = func.toString();
        let isUsualFunction = true;
        const parenthesisPos = funcString.indexOf(")");
        const arrowPos = funcString.indexOf("=>");
        if (arrowPos !== -1 && arrowPos > parenthesisPos) {
            isUsualFunction = false;
        }
        if (isUsualFunction) {
            return funcString.substring(funcString.indexOf("{", parenthesisPos) + 1, funcString.lastIndexOf("}"));
        }
        return funcString.substring(funcString.indexOf("=>") + 2);
    };
    const functionName = (func)=>{
        const funcString = func.toString();
        const isUsualFunction = funcString.indexOf("function") !== -1;
        if (isUsualFunction) {
            return funcString.substring(8, funcString.indexOf("{")).trim();
        }
        return funcString.substring(0, funcString.indexOf("=>") + 2).trim();
    };
    const lb = "{";
    const rb = "}";
    const PreFunctionType = (props)=>{
        return /*#__PURE__*/ jsxRuntimeExports.jsxs(NoSsr, {
            children: [
                /*#__PURE__*/ jsxRuntimeExports.jsx(DataTypeLabel, {
                    dataType: "function"
                }),
                /*#__PURE__*/ jsxRuntimeExports.jsxs(Box$1, {
                    component: "span",
                    className: "data-function-start",
                    sx: {
                        letterSpacing: 0.5
                    },
                    children: [
                        functionName(props.value),
                        " ",
                        lb
                    ]
                })
            ]
        });
    };
    const PostFunctionType = ()=>{
        return /*#__PURE__*/ jsxRuntimeExports.jsx(NoSsr, {
            children: /*#__PURE__*/ jsxRuntimeExports.jsx(Box$1, {
                component: "span",
                className: "data-function-end",
                children: rb
            })
        });
    };
    const FunctionType = (props)=>{
        const functionColor = useJsonViewerStore((store)=>store.colorspace.base05);
        return /*#__PURE__*/ jsxRuntimeExports.jsx(NoSsr, {
            children: /*#__PURE__*/ jsxRuntimeExports.jsx(Box$1, {
                className: "data-function",
                sx: {
                    display: props.inspect ? "block" : "inline-block",
                    pl: props.inspect ? 2 : 0,
                    color: functionColor
                },
                children: props.inspect ? functionBody(props.value) : /*#__PURE__*/ jsxRuntimeExports.jsx(Box$1, {
                    component: "span",
                    className: "data-function-body",
                    onClick: ()=>props.setInspect(true),
                    sx: {
                        "&:hover": {
                            cursor: "pointer"
                        },
                        padding: 0.5
                    },
                    children: "…"
                })
            })
        });
    };
    const functionType = {
        is: (value)=>typeof value === "function",
        Component: FunctionType,
        PreComponent: PreFunctionType,
        PostComponent: PostFunctionType
    };

    const nullType = defineEasyType({
        is: (value)=>value === null,
        type: "null",
        colorKey: "base08",
        displayTypeLabel: false,
        Renderer: ()=>{
            const backgroundColor = useJsonViewerStore((store)=>store.colorspace.base02);
            return /*#__PURE__*/ jsxRuntimeExports.jsx(Box$1, {
                sx: {
                    fontSize: "0.8rem",
                    backgroundColor,
                    fontWeight: "bold",
                    borderRadius: "3px",
                    padding: "0.5px 2px"
                },
                children: "NULL"
            });
        }
    });

    const isInt = (n)=>n % 1 === 0;
    const nanType = defineEasyType({
        is: (value)=>typeof value === "number" && isNaN(value),
        type: "NaN",
        colorKey: "base08",
        displayTypeLabel: false,
        serialize: ()=>"NaN",
        // allow deserialize the value back to number
        deserialize: (value)=>parseFloat(value),
        Renderer: ()=>{
            const backgroundColor = useJsonViewerStore((store)=>store.colorspace.base02);
            return /*#__PURE__*/ jsxRuntimeExports.jsx(Box$1, {
                sx: {
                    backgroundColor,
                    fontSize: "0.8rem",
                    fontWeight: "bold",
                    borderRadius: "3px",
                    padding: "0.5px 2px"
                },
                children: "NaN"
            });
        }
    });
    const floatType = defineEasyType({
        is: (value)=>typeof value === "number" && !isInt(value) && !isNaN(value),
        type: "float",
        colorKey: "base0B",
        serialize: (value)=>value.toString(),
        deserialize: (value)=>parseFloat(value),
        Renderer: (param)=> {
            let { value } = param;
            return jsxRuntimeExports.jsx(jsxRuntimeExports.Fragment, {
                children: value
            });
        }
    });
    const intType = defineEasyType({
        is: (value)=>typeof value === "number" && isInt(value),
        type: "int",
        colorKey: "base0F",
        serialize: (value)=>value.toString(),
        // allow deserialize the value to float
        deserialize: (value)=>parseFloat(value),
        Renderer: (param)=> {
            let { value } = param;
            return jsxRuntimeExports.jsx(jsxRuntimeExports.Fragment, {
                children: value
            });
        }
    });
    const bigIntType = defineEasyType({
        is: (value)=>typeof value === "bigint",
        type: "bigint",
        colorKey: "base0F",
        serialize: (value)=>value.toString(),
        deserialize: (value)=>BigInt(value.replace(/\D/g, "")),
        Renderer: (param)=> {
            let { value } = param;
            return jsxRuntimeExports.jsx(jsxRuntimeExports.Fragment, {
                children: "".concat(value, "n")
            });
        }
    });

    const BaseIcon = (param)=>{
        let { d, ...props } = param;
        return /*#__PURE__*/ jsxRuntimeExports.jsx(SvgIcon$1, {
            ...props,
            children: /*#__PURE__*/ jsxRuntimeExports.jsx("path", {
                d: d
            })
        });
    };
    const AddBox = "M19 3H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2m0 16H5V5h14zm-8-2h2v-4h4v-2h-4V7h-2v4H7v2h4z";
    const Check = "M9 16.17 4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z";
    const ChevronRight = "M10 6 8.59 7.41 13.17 12l-4.58 4.59L10 18l6-6z";
    const CircularArrows = "M 12 2 C 10.615 1.998 9.214625 2.2867656 7.890625 2.8847656 L 8.9003906 4.6328125 C 9.9043906 4.2098125 10.957 3.998 12 4 C 15.080783 4 17.738521 5.7633175 19.074219 8.3222656 L 17.125 9 L 21.25 11 L 22.875 7 L 20.998047 7.6523438 C 19.377701 4.3110398 15.95585 2 12 2 z M 6.5097656 4.4882812 L 2.2324219 5.0820312 L 3.734375 6.3808594 C 1.6515335 9.4550558 1.3615962 13.574578 3.3398438 17 C 4.0308437 18.201 4.9801562 19.268234 6.1601562 20.115234 L 7.1699219 18.367188 C 6.3019219 17.710187 5.5922656 16.904 5.0722656 16 C 3.5320014 13.332354 3.729203 10.148679 5.2773438 7.7128906 L 6.8398438 9.0625 L 6.5097656 4.4882812 z M 19.929688 13 C 19.794687 14.08 19.450734 15.098 18.927734 16 C 17.386985 18.668487 14.531361 20.090637 11.646484 19.966797 L 12.035156 17.9375 L 8.2402344 20.511719 L 10.892578 23.917969 L 11.265625 21.966797 C 14.968963 22.233766 18.681899 20.426323 20.660156 17 C 21.355156 15.801 21.805219 14.445 21.949219 13 L 19.929688 13 z";
    const Close = "M19 6.41 17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z";
    const ContentCopy = "M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z";
    const Edit = "M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34a.9959.9959 0 0 0-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z";
    const ExpandMore = "M16.59 8.59 12 13.17 7.41 8.59 6 10l6 6 6-6z";
    const Delete = "M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6zM8 9h8v10H8zm7.5-5l-1-1h-5l-1 1H5v2h14V4z";
    const AddBoxIcon = (props)=>{
        return /*#__PURE__*/ jsxRuntimeExports.jsx(BaseIcon, {
            d: AddBox,
            ...props
        });
    };
    const CheckIcon = (props)=>{
        return /*#__PURE__*/ jsxRuntimeExports.jsx(BaseIcon, {
            d: Check,
            ...props
        });
    };
    const ChevronRightIcon = (props)=>{
        return /*#__PURE__*/ jsxRuntimeExports.jsx(BaseIcon, {
            d: ChevronRight,
            ...props
        });
    };
    const CircularArrowsIcon = (props)=>{
        return /*#__PURE__*/ jsxRuntimeExports.jsx(BaseIcon, {
            d: CircularArrows,
            ...props
        });
    };
    const CloseIcon = (props)=>{
        return /*#__PURE__*/ jsxRuntimeExports.jsx(BaseIcon, {
            d: Close,
            ...props
        });
    };
    const ContentCopyIcon = (props)=>{
        return /*#__PURE__*/ jsxRuntimeExports.jsx(BaseIcon, {
            d: ContentCopy,
            ...props
        });
    };
    const EditIcon = (props)=>{
        return /*#__PURE__*/ jsxRuntimeExports.jsx(BaseIcon, {
            d: Edit,
            ...props
        });
    };
    const ExpandMoreIcon = (props)=>{
        return /*#__PURE__*/ jsxRuntimeExports.jsx(BaseIcon, {
            d: ExpandMore,
            ...props
        });
    };
    const DeleteIcon = (props)=>{
        return /*#__PURE__*/ jsxRuntimeExports.jsx(BaseIcon, {
            d: Delete,
            ...props
        });
    };

    const objectLb = "{";
    const arrayLb = "[";
    const objectRb = "}";
    const arrayRb = "]";
    function inspectMetadata(value) {
        const length = getValueSize(value);
        let name = "";
        if (value instanceof Map || value instanceof Set) {
            name = value[Symbol.toStringTag];
        }
        if (Object.prototype.hasOwnProperty.call(value, Symbol.toStringTag)) {
            name = value[Symbol.toStringTag];
        }
        return "".concat(length, " Items").concat(name ? " (".concat(name, ")") : "");
    }
    const PreObjectType = (props)=>{
        const metadataColor = useJsonViewerStore((store)=>store.colorspace.base04);
        const textColor = useTextColor();
        const isArray = reactExports.useMemo(()=>Array.isArray(props.value), [
            props.value
        ]);
        const isEmptyValue = reactExports.useMemo(()=>getValueSize(props.value) === 0, [
            props.value
        ]);
        const sizeOfValue = reactExports.useMemo(()=>inspectMetadata(props.value), [
            props.value
        ]);
        const displaySize = useJsonViewerStore((store)=>store.displaySize);
        const shouldDisplaySize = reactExports.useMemo(()=>typeof displaySize === "function" ? displaySize(props.path, props.value) : displaySize, [
            displaySize,
            props.path,
            props.value
        ]);
        const isTrap = useIsCycleReference(props.path, props.value);
        return /*#__PURE__*/ jsxRuntimeExports.jsxs(Box$1, {
            component: "span",
            className: "data-object-start",
            sx: {
                letterSpacing: 0.5
            },
            children: [
                isArray ? arrayLb : objectLb,
                shouldDisplaySize && props.inspect && !isEmptyValue && /*#__PURE__*/ jsxRuntimeExports.jsx(Box$1, {
                    component: "span",
                    sx: {
                        pl: 0.5,
                        fontStyle: "italic",
                        color: metadataColor,
                        userSelect: "none"
                    },
                    children: sizeOfValue
                }),
                isTrap && !props.inspect && /*#__PURE__*/ jsxRuntimeExports.jsxs(jsxRuntimeExports.Fragment, {
                    children: [
                        /*#__PURE__*/ jsxRuntimeExports.jsx(CircularArrowsIcon, {
                            sx: {
                                fontSize: 12,
                                color: textColor,
                                mx: 0.5
                            }
                        }),
                        isTrap
                    ]
                })
            ]
        });
    };
    const PostObjectType = (props)=>{
        const metadataColor = useJsonViewerStore((store)=>store.colorspace.base04);
        const textColor = useTextColor();
        const isArray = reactExports.useMemo(()=>Array.isArray(props.value), [
            props.value
        ]);
        const isEmptyValue = reactExports.useMemo(()=>getValueSize(props.value) === 0, [
            props.value
        ]);
        const sizeOfValue = reactExports.useMemo(()=>inspectMetadata(props.value), [
            props.value
        ]);
        const displaySize = useJsonViewerStore((store)=>store.displaySize);
        const shouldDisplaySize = reactExports.useMemo(()=>typeof displaySize === "function" ? displaySize(props.path, props.value) : displaySize, [
            displaySize,
            props.path,
            props.value
        ]);
        return /*#__PURE__*/ jsxRuntimeExports.jsxs(Box$1, {
            component: "span",
            className: "data-object-end",
            sx: {
                lineHeight: 1.5,
                color: textColor,
                letterSpacing: 0.5,
                opacity: 0.8
            },
            children: [
                isArray ? arrayRb : objectRb,
                shouldDisplaySize && (isEmptyValue || !props.inspect) ? /*#__PURE__*/ jsxRuntimeExports.jsx(Box$1, {
                    component: "span",
                    sx: {
                        pl: 0.5,
                        fontStyle: "italic",
                        color: metadataColor,
                        userSelect: "none"
                    },
                    children: sizeOfValue
                }) : null
            ]
        });
    };
    function getIterator(value) {
        var _value;
        return typeof ((_value = value) === null || _value === void 0 ? void 0 : _value[Symbol.iterator]) === "function";
    }
    const ObjectType = (props)=>{
        const keyColor = useTextColor();
        const borderColor = useJsonViewerStore((store)=>store.colorspace.base02);
        const groupArraysAfterLength = useJsonViewerStore((store)=>store.groupArraysAfterLength);
        const isTrap = useIsCycleReference(props.path, props.value);
        const [displayLength, setDisplayLength] = reactExports.useState(useJsonViewerStore((store)=>store.maxDisplayLength));
        const objectSortKeys = useJsonViewerStore((store)=>store.objectSortKeys);
        const elements = reactExports.useMemo(()=>{
            if (!props.inspect) {
                return null;
            }
            const value = props.value;
            const iterator = getIterator(value);
            // Array also has iterator, we skip it and treat it as an array as normal.
            if (iterator && !Array.isArray(value)) {
                const elements = [];
                if (value instanceof Map) {
                    value.forEach((value, k)=>{
                        // fixme: key might be a object, array, or any value for the `Map<any, any>`
                        const key = k.toString();
                        const path = [
                            ...props.path,
                            key
                        ];
                        elements.push(/*#__PURE__*/ jsxRuntimeExports.jsx(DataKeyPair, {
                            path: path,
                            value: value,
                            prevValue: props.prevValue instanceof Map ? props.prevValue.get(k) : undefined,
                            editable: false
                        }, key));
                    });
                } else {
                    // iterate with iterator func
                    const iterator = value[Symbol.iterator]();
                    let result = iterator.next();
                    let count = 0;
                    while(!result.done){
                        elements.push(/*#__PURE__*/ jsxRuntimeExports.jsx(DataKeyPair, {
                            path: [
                                ...props.path,
                                "iterator:".concat(count)
                            ],
                            value: result.value,
                            nestedIndex: count,
                            editable: false
                        }, count));
                        count++;
                        result = iterator.next();
                    }
                }
                return elements;
            }
            if (Array.isArray(value)) {
                // unknown[]
                if (value.length <= groupArraysAfterLength) {
                    const elements = value.slice(0, displayLength).map((value, _index)=>{
                        const index = props.nestedIndex ? props.nestedIndex * groupArraysAfterLength + _index : _index;
                        const path = [
                            ...props.path,
                            index
                        ];
                        return /*#__PURE__*/ jsxRuntimeExports.jsx(DataKeyPair, {
                            path: path,
                            value: value,
                            prevValue: Array.isArray(props.prevValue) ? props.prevValue[index] : undefined
                        }, index);
                    });
                    if (value.length > displayLength) {
                        const rest = value.length - displayLength;
                        elements.push(/*#__PURE__*/ jsxRuntimeExports.jsxs(DataBox, {
                            sx: {
                                cursor: "pointer",
                                lineHeight: 1.5,
                                color: keyColor,
                                letterSpacing: 0.5,
                                opacity: 0.8,
                                userSelect: "none"
                            },
                            onClick: ()=>setDisplayLength((length)=>length * 2),
                            children: [
                                "hidden ",
                                rest,
                                " items…"
                            ]
                        }, "last"));
                    }
                    return elements;
                }
                const elements = segmentArray(value, groupArraysAfterLength);
                const prevElements = Array.isArray(props.prevValue) ? segmentArray(props.prevValue, groupArraysAfterLength) : undefined;
                return elements.map((list, index)=>{
                    var _prevElements;
                    return /*#__PURE__*/ jsxRuntimeExports.jsx(DataKeyPair, {
                        path: props.path,
                        value: list,
                        nestedIndex: index,
                        prevValue: (_prevElements = prevElements) === null || _prevElements === void 0 ? void 0 : _prevElements[index]
                    }, index);
                });
            }
            // object
            let entries = Object.entries(value);
            if (objectSortKeys) {
                entries = objectSortKeys === true ? entries.sort((param, param1)=>{
                    let [a] = param, [b] = param1;
                    return a.localeCompare(b);
                }) : entries.sort((param, param1)=>{
                    let [a] = param, [b] = param1;
                    return objectSortKeys(a, b);
                });
            }
            const elements = entries.slice(0, displayLength).map((param)=>{
                let [key, value] = param;
                var _props_prevValue;
                const path = [
                    ...props.path,
                    key
                ];
                return /*#__PURE__*/ jsxRuntimeExports.jsx(DataKeyPair, {
                    path: path,
                    value: value,
                    prevValue: (_props_prevValue = props.prevValue) === null || _props_prevValue === void 0 ? void 0 : _props_prevValue[key]
                }, key);
            });
            if (entries.length > displayLength) {
                const rest = entries.length - displayLength;
                elements.push(/*#__PURE__*/ jsxRuntimeExports.jsxs(DataBox, {
                    sx: {
                        cursor: "pointer",
                        lineHeight: 1.5,
                        color: keyColor,
                        letterSpacing: 0.5,
                        opacity: 0.8,
                        userSelect: "none"
                    },
                    onClick: ()=>setDisplayLength((length)=>length * 2),
                    children: [
                        "hidden ",
                        rest,
                        " items…"
                    ]
                }, "last"));
            }
            return elements;
        }, [
            props.inspect,
            props.value,
            props.prevValue,
            props.path,
            props.nestedIndex,
            groupArraysAfterLength,
            displayLength,
            keyColor,
            objectSortKeys
        ]);
        const marginLeft = props.inspect ? 0.6 : 0;
        const width = useJsonViewerStore((store)=>store.indentWidth);
        const indentWidth = props.inspect ? width - marginLeft : width;
        const isEmptyValue = reactExports.useMemo(()=>getValueSize(props.value) === 0, [
            props.value
        ]);
        if (isEmptyValue) {
            return null;
        }
        return /*#__PURE__*/ jsxRuntimeExports.jsx(Box$1, {
            className: "data-object",
            sx: {
                display: props.inspect ? "block" : "inline-block",
                pl: props.inspect ? indentWidth - 0.6 : 0,
                marginLeft,
                color: keyColor,
                borderLeft: props.inspect ? "1px solid ".concat(borderColor) : "none"
            },
            children: props.inspect ? elements : !isTrap && /*#__PURE__*/ jsxRuntimeExports.jsx(Box$1, {
                component: "span",
                className: "data-object-body",
                onClick: ()=>props.setInspect(true),
                sx: {
                    "&:hover": {
                        cursor: "pointer"
                    },
                    padding: 0.5,
                    userSelect: "none"
                },
                children: "…"
            })
        });
    };
    const objectType = {
        is: (value)=>typeof value === "object",
        Component: ObjectType,
        PreComponent: PreObjectType,
        PostComponent: PostObjectType
    };

    const stringType = defineEasyType({
        is: (value)=>typeof value === "string",
        type: "string",
        colorKey: "base09",
        serialize: (value)=>value,
        deserialize: (value)=>value,
        Renderer: (props)=>{
            const [showRest, setShowRest] = reactExports.useState(false);
            const collapseStringsAfterLength = useJsonViewerStore((store)=>store.collapseStringsAfterLength);
            const value = showRest ? props.value : props.value.slice(0, collapseStringsAfterLength);
            const hasRest = props.value.length > collapseStringsAfterLength;
            return /*#__PURE__*/ jsxRuntimeExports.jsxs(Box$1, {
                component: "span",
                sx: {
                    overflowWrap: "anywhere",
                    cursor: hasRest ? "pointer" : "inherit"
                },
                onClick: ()=>{
                    var _window_getSelection;
                    if (((_window_getSelection = window.getSelection()) === null || _window_getSelection === void 0 ? void 0 : _window_getSelection.type) === "Range") {
                        return;
                    }
                    if (hasRest) {
                        setShowRest((value)=>!value);
                    }
                },
                children: [
                    '"',
                    value,
                    hasRest && !showRest && /*#__PURE__*/ jsxRuntimeExports.jsx(Box$1, {
                        component: "span",
                        sx: {
                            padding: 0.5
                        },
                        children: "…"
                    }),
                    '"'
                ]
            });
        }
    });

    const undefinedType = defineEasyType({
        is: (value)=>value === undefined,
        type: "undefined",
        colorKey: "base05",
        displayTypeLabel: false,
        Renderer: ()=>{
            const backgroundColor = useJsonViewerStore((store)=>store.colorspace.base02);
            return /*#__PURE__*/ jsxRuntimeExports.jsx(Box$1, {
                sx: {
                    fontSize: "0.7rem",
                    backgroundColor,
                    borderRadius: "3px",
                    padding: "0.5px 2px"
                },
                children: "undefined"
            });
        }
    });

    var dataTypes = /*#__PURE__*/Object.freeze({
        __proto__: null,
        bigIntType: bigIntType,
        booleanType: booleanType,
        dateType: dateType,
        defineEasyType: defineEasyType,
        floatType: floatType,
        functionType: functionType,
        intType: intType,
        nanType: nanType,
        nullType: nullType,
        objectType: objectType,
        stringType: stringType,
        undefinedType: undefinedType
    });

    const createTypeRegistryStore = ()=>{
        return createStore()((set)=>({
                registry: [],
                registerTypes: (setState)=>{
                    set((state)=>({
                            registry: typeof setState === "function" ? setState(state.registry) : setState
                        }));
                }
            }));
    };
    // @ts-expect-error we intentionally want to pass undefined to the context
    // See https://github.com/DefinitelyTyped/DefinitelyTyped/pull/24509#issuecomment-382213106
    const TypeRegistryStoreContext = /*#__PURE__*/ reactExports.createContext(undefined);
    TypeRegistryStoreContext.Provider;
    const useTypeRegistryStore = (selector, equalityFn)=>{
        const store = reactExports.useContext(TypeRegistryStoreContext);
        return useStore(store, selector, equalityFn);
    };
    function matchTypeComponents(value, path, registry) {
        let potential;
        for (const T of registry){
            if (T.is(value, path)) {
                potential = T;
            }
        }
        if (potential === undefined) {
            if (typeof value === "object") {
                return objectType;
            }
            throw new Error("No type matched for value: ".concat(value));
        }
        return potential;
    }
    function useTypeComponents(value, path) {
        const registry = useTypeRegistryStore((store)=>store.registry);
        return reactExports.useMemo(()=>matchTypeComponents(value, path, registry), [
            value,
            path,
            registry
        ]);
    }
    function memorizeDataType(dataType) {
        function compare(prevProps, nextProps) {
            var _prevProps_path, _nextProps_path;
            return Object.is(prevProps.value, nextProps.value) && prevProps.inspect && nextProps.inspect && ((_prevProps_path = prevProps.path) === null || _prevProps_path === void 0 ? void 0 : _prevProps_path.join(".")) === ((_nextProps_path = nextProps.path) === null || _nextProps_path === void 0 ? void 0 : _nextProps_path.join("."));
        }
        dataType.Component = /*#__PURE__*/ reactExports.memo(dataType.Component, compare);
        if (dataType.Editor) {
            dataType.Editor = /*#__PURE__*/ reactExports.memo(dataType.Editor, function compare(prevProps, nextProps) {
                return Object.is(prevProps.value, nextProps.value);
            });
        }
        if (dataType.PreComponent) {
            dataType.PreComponent = /*#__PURE__*/ reactExports.memo(dataType.PreComponent, compare);
        }
        if (dataType.PostComponent) {
            dataType.PostComponent = /*#__PURE__*/ reactExports.memo(dataType.PostComponent, compare);
        }
        return dataType;
    }
    const predefinedTypes = [
        memorizeDataType(booleanType),
        memorizeDataType(dateType),
        memorizeDataType(nullType),
        memorizeDataType(undefinedType),
        memorizeDataType(stringType),
        memorizeDataType(functionType),
        memorizeDataType(nanType),
        memorizeDataType(intType),
        memorizeDataType(floatType),
        memorizeDataType(bigIntType)
    ];

    const IconBox = (props)=>/*#__PURE__*/ jsxRuntimeExports.jsx(Box$1, {
            component: "span",
            ...props,
            sx: {
                cursor: "pointer",
                paddingLeft: "0.7rem",
                ...props.sx
            }
        });
    const DataKeyPair = (props)=>{
        const { value, prevValue, path, nestedIndex } = props;
        const { Component, PreComponent, PostComponent, Editor, serialize, deserialize } = useTypeComponents(value, path);
        var _props_editable;
        const propsEditable = (_props_editable = props.editable) !== null && _props_editable !== void 0 ? _props_editable : undefined;
        const storeEditable = useJsonViewerStore((store)=>store.editable);
        const editable = reactExports.useMemo(()=>{
            if (storeEditable === false) {
                return false;
            }
            if (propsEditable === false) {
                // props.editable is false which means we cannot provide the suitable way to edit it
                return false;
            }
            if (typeof storeEditable === "function") {
                return !!storeEditable(path, value);
            }
            return storeEditable;
        }, [
            path,
            propsEditable,
            storeEditable,
            value
        ]);
        const [tempValue, setTempValue] = reactExports.useState("");
        const depth = path.length;
        const key = path[depth - 1];
        const hoverPath = useJsonViewerStore((store)=>store.hoverPath);
        const isHover = reactExports.useMemo(()=>{
            return hoverPath && path.every((value, index)=>value === hoverPath.path[index] && nestedIndex === hoverPath.nestedIndex);
        }, [
            hoverPath,
            path,
            nestedIndex
        ]);
        const setHover = useJsonViewerStore((store)=>store.setHover);
        const root = useJsonViewerStore((store)=>store.value);
        const [inspect, setInspect] = useInspect(path, value, nestedIndex);
        const [editing, setEditing] = reactExports.useState(false);
        const onChange = useJsonViewerStore((store)=>store.onChange);
        const keyColor = useTextColor();
        const numberKeyColor = useJsonViewerStore((store)=>store.colorspace.base0C);
        const highlightColor = useJsonViewerStore((store)=>store.colorspace.base0A);
        const quotesOnKeys = useJsonViewerStore((store)=>store.quotesOnKeys);
        const rootName = useJsonViewerStore((store)=>store.rootName);
        const isRoot = root === value;
        const isNumberKey = Number.isInteger(Number(key));
        const storeEnableAdd = useJsonViewerStore((store)=>store.enableAdd);
        const onAdd = useJsonViewerStore((store)=>store.onAdd);
        const enableAdd = reactExports.useMemo(()=>{
            if (!onAdd || nestedIndex !== undefined) return false;
            if (storeEnableAdd === false) {
                return false;
            }
            if (propsEditable === false) {
                // props.editable is false which means we cannot provide the suitable way to edit it
                return false;
            }
            if (typeof storeEnableAdd === "function") {
                return !!storeEnableAdd(path, value);
            }
            if (Array.isArray(value) || isPlainObject(value)) {
                return true;
            }
            return false;
        }, [
            onAdd,
            nestedIndex,
            path,
            storeEnableAdd,
            propsEditable,
            value
        ]);
        const storeEnableDelete = useJsonViewerStore((store)=>store.enableDelete);
        const onDelete = useJsonViewerStore((store)=>store.onDelete);
        const enableDelete = reactExports.useMemo(()=>{
            if (!onDelete || nestedIndex !== undefined) return false;
            if (isRoot) {
                // don't allow delete root
                return false;
            }
            if (storeEnableDelete === false) {
                return false;
            }
            if (propsEditable === false) {
                // props.editable is false which means we cannot provide the suitable way to edit it
                return false;
            }
            if (typeof storeEnableDelete === "function") {
                return !!storeEnableDelete(path, value);
            }
            return storeEnableDelete;
        }, [
            onDelete,
            nestedIndex,
            isRoot,
            path,
            storeEnableDelete,
            propsEditable,
            value
        ]);
        const enableClipboard = useJsonViewerStore((store)=>store.enableClipboard);
        const { copy, copied } = useClipboard();
        const highlightUpdates = useJsonViewerStore((store)=>store.highlightUpdates);
        const isHighlight = reactExports.useMemo(()=>{
            if (!highlightUpdates || prevValue === undefined) return false;
            // highlight if value type changed
            if (typeof value !== typeof prevValue) {
                return true;
            }
            if (typeof value === "number") {
                // notice: NaN !== NaN
                if (isNaN(value) && isNaN(prevValue)) return false;
                return value !== prevValue;
            }
            // highlight if isArray changed
            if (Array.isArray(value) !== Array.isArray(prevValue)) {
                return true;
            }
            // not highlight object/function
            // deep compare they will be slow
            if (typeof value === "object" || typeof value === "function") {
                return false;
            }
            // highlight if not equal
            if (value !== prevValue) {
                return true;
            }
            return false;
        }, [
            highlightUpdates,
            prevValue,
            value
        ]);
        const highlightContainer = reactExports.useRef();
        reactExports.useEffect(()=>{
            if (highlightContainer.current && isHighlight && "animate" in highlightContainer.current) {
                highlightContainer.current.animate([
                    {
                        backgroundColor: highlightColor
                    },
                    {
                        backgroundColor: ""
                    }
                ], {
                    duration: 1000,
                    easing: "ease-in"
                });
            }
        }, [
            highlightColor,
            isHighlight,
            prevValue,
            value
        ]);
        const startEditing = reactExports.useCallback((event)=>{
            event.preventDefault();
            if (serialize) setTempValue(serialize(value));
            setEditing(true);
        }, [
            serialize,
            value
        ]);
        const abortEditing = reactExports.useCallback(()=>{
            setEditing(false);
            setTempValue("");
        }, [
            setEditing,
            setTempValue
        ]);
        const commitEditing = reactExports.useCallback((newValue)=>{
            setEditing(false);
            if (!deserialize) return;
            try {
                onChange(path, value, deserialize(newValue));
            } catch (e) {
            // do nothing when deserialize failed
            }
        }, [
            setEditing,
            deserialize,
            onChange,
            path,
            value
        ]);
        const actionIcons = reactExports.useMemo(()=>{
            if (editing) {
                return /*#__PURE__*/ jsxRuntimeExports.jsxs(jsxRuntimeExports.Fragment, {
                    children: [
                        /*#__PURE__*/ jsxRuntimeExports.jsx(IconBox, {
                            children: /*#__PURE__*/ jsxRuntimeExports.jsx(CloseIcon, {
                                sx: {
                                    fontSize: ".8rem"
                                },
                                onClick: abortEditing
                            })
                        }),
                        /*#__PURE__*/ jsxRuntimeExports.jsx(IconBox, {
                            children: /*#__PURE__*/ jsxRuntimeExports.jsx(CheckIcon, {
                                sx: {
                                    fontSize: ".8rem"
                                },
                                onClick: ()=>commitEditing(tempValue)
                            })
                        })
                    ]
                });
            }
            return /*#__PURE__*/ jsxRuntimeExports.jsxs(jsxRuntimeExports.Fragment, {
                children: [
                    enableClipboard && /*#__PURE__*/ jsxRuntimeExports.jsx(IconBox, {
                        onClick: (event)=>{
                            event.preventDefault();
                            try {
                                copy(path, value, copyString);
                            } catch (e) {
                                // in some case, this will throw error
                                // fixme: `useAlert` hook
                                console.error(e);
                            }
                        },
                        children: copied ? /*#__PURE__*/ jsxRuntimeExports.jsx(CheckIcon, {
                            sx: {
                                fontSize: ".8rem"
                            }
                        }) : /*#__PURE__*/ jsxRuntimeExports.jsx(ContentCopyIcon, {
                            sx: {
                                fontSize: ".8rem"
                            }
                        })
                    }),
                    Editor && editable && serialize && deserialize && /*#__PURE__*/ jsxRuntimeExports.jsx(IconBox, {
                        onClick: startEditing,
                        children: /*#__PURE__*/ jsxRuntimeExports.jsx(EditIcon, {
                            sx: {
                                fontSize: ".8rem"
                            }
                        })
                    }),
                    enableAdd && /*#__PURE__*/ jsxRuntimeExports.jsx(IconBox, {
                        onClick: (event)=>{
                            var _onAdd;
                            event.preventDefault();
                            (_onAdd = onAdd) === null || _onAdd === void 0 ? void 0 : _onAdd(path);
                        },
                        children: /*#__PURE__*/ jsxRuntimeExports.jsx(AddBoxIcon, {
                            sx: {
                                fontSize: ".8rem"
                            }
                        })
                    }),
                    enableDelete && /*#__PURE__*/ jsxRuntimeExports.jsx(IconBox, {
                        onClick: (event)=>{
                            var _onDelete;
                            event.preventDefault();
                            (_onDelete = onDelete) === null || _onDelete === void 0 ? void 0 : _onDelete(path, value);
                        },
                        children: /*#__PURE__*/ jsxRuntimeExports.jsx(DeleteIcon, {
                            sx: {
                                fontSize: ".9rem"
                            }
                        })
                    })
                ]
            });
        }, [
            Editor,
            serialize,
            deserialize,
            copied,
            copy,
            editable,
            editing,
            enableClipboard,
            enableAdd,
            enableDelete,
            tempValue,
            path,
            value,
            onAdd,
            onDelete,
            startEditing,
            abortEditing,
            commitEditing
        ]);
        const isEmptyValue = reactExports.useMemo(()=>getValueSize(value) === 0, [
            value
        ]);
        const expandable = !isEmptyValue && !!(PreComponent && PostComponent);
        const KeyRenderer = useJsonViewerStore((store)=>store.keyRenderer);
        const downstreamProps = reactExports.useMemo(()=>({
                path,
                inspect,
                setInspect,
                value,
                prevValue,
                nestedIndex
            }), [
            inspect,
            path,
            setInspect,
            value,
            prevValue,
            nestedIndex
        ]);
        return /*#__PURE__*/ jsxRuntimeExports.jsxs(Box$1, {
            className: "data-key-pair",
            "data-testid": "data-key-pair" + path.join("."),
            sx: {
                userSelect: "text"
            },
            onMouseEnter: reactExports.useCallback(()=>setHover(path, nestedIndex), [
                setHover,
                path,
                nestedIndex
            ]),
            children: [
                /*#__PURE__*/ jsxRuntimeExports.jsxs(DataBox, {
                    component: "span",
                    className: "data-key",
                    sx: {
                        lineHeight: 1.5,
                        color: keyColor,
                        letterSpacing: 0.5,
                        opacity: 0.8
                    },
                    onClick: reactExports.useCallback((event)=>{
                        if (event.isDefaultPrevented()) {
                            return;
                        }
                        if (!isEmptyValue) {
                            setInspect((state)=>!state);
                        }
                    }, [
                        isEmptyValue,
                        setInspect
                    ]),
                    children: [
                        expandable ? inspect ? /*#__PURE__*/ jsxRuntimeExports.jsx(ExpandMoreIcon, {
                            sx: {
                                fontSize: ".8rem",
                                "&:hover": {
                                    cursor: "pointer"
                                }
                            }
                        }) : /*#__PURE__*/ jsxRuntimeExports.jsx(ChevronRightIcon, {
                            sx: {
                                fontSize: ".8rem",
                                "&:hover": {
                                    cursor: "pointer"
                                }
                            }
                        }) : null,
                        /*#__PURE__*/ jsxRuntimeExports.jsx(Box$1, {
                            ref: highlightContainer,
                            component: "span",
                            children: isRoot && depth === 0 ? rootName !== false ? quotesOnKeys ? /*#__PURE__*/ jsxRuntimeExports.jsxs(jsxRuntimeExports.Fragment, {
                                children: [
                                    '"',
                                    rootName,
                                    '"'
                                ]
                            }) : /*#__PURE__*/ jsxRuntimeExports.jsx(jsxRuntimeExports.Fragment, {
                                children: rootName
                            }) : null : KeyRenderer.when(downstreamProps) ? /*#__PURE__*/ jsxRuntimeExports.jsx(KeyRenderer, {
                                ...downstreamProps
                            }) : nestedIndex === undefined && (isNumberKey ? /*#__PURE__*/ jsxRuntimeExports.jsx(Box$1, {
                                component: "span",
                                style: {
                                    color: numberKeyColor
                                },
                                children: key
                            }) : quotesOnKeys ? /*#__PURE__*/ jsxRuntimeExports.jsxs(jsxRuntimeExports.Fragment, {
                                children: [
                                    '"',
                                    key,
                                    '"'
                                ]
                            }) : /*#__PURE__*/ jsxRuntimeExports.jsx(jsxRuntimeExports.Fragment, {
                                children: key
                            }))
                        }),
                        isRoot ? rootName !== false && /*#__PURE__*/ jsxRuntimeExports.jsx(DataBox, {
                            sx: {
                                mr: 0.5
                            },
                            children: ":"
                        }) : nestedIndex === undefined && /*#__PURE__*/ jsxRuntimeExports.jsx(DataBox, {
                            sx: {
                                mr: 0.5
                            },
                            children: ":"
                        }),
                        PreComponent && /*#__PURE__*/ jsxRuntimeExports.jsx(PreComponent, {
                            ...downstreamProps
                        }),
                        isHover && expandable && inspect && actionIcons
                    ]
                }),
                editing && editable ? Editor && /*#__PURE__*/ jsxRuntimeExports.jsx(Editor, {
                    value: tempValue,
                    setValue: setTempValue,
                    abortEditing: abortEditing,
                    commitEditing: commitEditing
                }) : Component ? /*#__PURE__*/ jsxRuntimeExports.jsx(Component, {
                    ...downstreamProps
                }) : /*#__PURE__*/ jsxRuntimeExports.jsx(Box$1, {
                    component: "span",
                    className: "data-value-fallback",
                    children: "fallback: ".concat(value)
                }),
                PostComponent && /*#__PURE__*/ jsxRuntimeExports.jsx(PostComponent, {
                    ...downstreamProps
                }),
                isHover && expandable && !inspect && actionIcons,
                isHover && !expandable && actionIcons,
                !isHover && editing && actionIcons
            ]
        });
    };

    const query = "(prefers-color-scheme: dark)";
    function useThemeDetector() {
        const [isDark, setIsDark] = reactExports.useState(false);
        reactExports.useEffect(()=>{
            const listener = (e)=>setIsDark(e.matches);
            setIsDark(window.matchMedia(query).matches);
            const queryMedia = window.matchMedia(query);
            queryMedia.addEventListener("change", listener);
            return ()=>queryMedia.removeEventListener("change", listener);
        }, []);
        return isDark;
    }

    /**
     * @internal
     */ function useSetIfNotUndefinedEffect(key, value) {
        const { setState } = reactExports.useContext(JsonViewerStoreContext);
        reactExports.useEffect(()=>{
            if (value !== undefined) {
                setState({
                    [key]: value
                });
            }
        }, [
            key,
            value,
            setState
        ]);
    }
    /**
     * @internal
     */ const JsonViewerInner = (props)=>{
        const { setState } = reactExports.useContext(JsonViewerStoreContext);
        reactExports.useEffect(()=>{
            setState((state)=>({
                    prevValue: state.value,
                    value: props.value
                }));
        }, [
            props.value,
            setState
        ]);
        useSetIfNotUndefinedEffect("rootName", props.rootName);
        useSetIfNotUndefinedEffect("indentWidth", props.indentWidth);
        useSetIfNotUndefinedEffect("keyRenderer", props.keyRenderer);
        useSetIfNotUndefinedEffect("enableAdd", props.enableAdd);
        useSetIfNotUndefinedEffect("enableDelete", props.enableDelete);
        useSetIfNotUndefinedEffect("enableClipboard", props.enableClipboard);
        useSetIfNotUndefinedEffect("editable", props.editable);
        useSetIfNotUndefinedEffect("onChange", props.onChange);
        useSetIfNotUndefinedEffect("onCopy", props.onCopy);
        useSetIfNotUndefinedEffect("onSelect", props.onSelect);
        useSetIfNotUndefinedEffect("onAdd", props.onAdd);
        useSetIfNotUndefinedEffect("onDelete", props.onDelete);
        useSetIfNotUndefinedEffect("maxDisplayLength", props.maxDisplayLength);
        useSetIfNotUndefinedEffect("groupArraysAfterLength", props.groupArraysAfterLength);
        useSetIfNotUndefinedEffect("displayDataTypes", props.displayDataTypes);
        useSetIfNotUndefinedEffect("displaySize", props.displaySize);
        useSetIfNotUndefinedEffect("highlightUpdates", props.highlightUpdates);
        reactExports.useEffect(()=>{
            if (props.theme === "light") {
                setState({
                    colorspace: lightColorspace
                });
            } else if (props.theme === "dark") {
                setState({
                    colorspace: darkColorspace
                });
            } else if (typeof props.theme === "object") {
                setState({
                    colorspace: props.theme
                });
            }
        }, [
            setState,
            props.theme
        ]);
        const themeCls = reactExports.useMemo(()=>{
            if (typeof props.theme === "object") return "json-viewer-theme-custom";
            return props.theme === "dark" ? "json-viewer-theme-dark" : "json-viewer-theme-light";
        }, [
            props.theme
        ]);
        const onceRef = reactExports.useRef(true);
        const registerTypes = useTypeRegistryStore((store)=>store.registerTypes);
        if (onceRef.current) {
            const allTypes = props.valueTypes ? [
                ...predefinedTypes,
                ...props.valueTypes
            ] : [
                ...predefinedTypes
            ];
            registerTypes(allTypes);
            onceRef.current = false;
        }
        reactExports.useEffect(()=>{
            const allTypes = props.valueTypes ? [
                ...predefinedTypes,
                ...props.valueTypes
            ] : [
                ...predefinedTypes
            ];
            registerTypes(allTypes);
        }, [
            props.valueTypes,
            registerTypes
        ]);
        const value = useJsonViewerStore((store)=>store.value);
        const prevValue = useJsonViewerStore((store)=>store.prevValue);
        const emptyPath = reactExports.useMemo(()=>[], []);
        const setHover = useJsonViewerStore((store)=>store.setHover);
        const onMouseLeave = reactExports.useCallback(()=>setHover(null), [
            setHover
        ]);
        return /*#__PURE__*/ jsxRuntimeExports.jsx(Paper$1, {
            elevation: 0,
            className: clsx(themeCls, props.className),
            style: props.style,
            sx: {
                fontFamily: "monospace",
                userSelect: "none",
                contentVisibility: "auto",
                ...props.sx
            },
            onMouseLeave: onMouseLeave,
            children: /*#__PURE__*/ jsxRuntimeExports.jsx(DataKeyPair, {
                value: value,
                prevValue: prevValue,
                path: emptyPath
            })
        });
    };
    const JsonViewer$1 = function JsonViewer(props) {
        const isAutoDarkTheme = useThemeDetector();
        var _props_theme;
        const themeType = reactExports.useMemo(()=>props.theme === "auto" ? isAutoDarkTheme ? "light" : "dark" : (_props_theme = props.theme) !== null && _props_theme !== void 0 ? _props_theme : "light", [
            isAutoDarkTheme,
            props.theme
        ]);
        const theme = reactExports.useMemo(()=>{
            const backgroundColor = typeof themeType === "object" ? themeType.base00 : themeType === "dark" ? darkColorspace.base00 : lightColorspace.base00;
            const foregroundColor = typeof themeType === "object" ? themeType.base07 : themeType === "dark" ? darkColorspace.base07 : lightColorspace.base07;
            return createTheme({
                components: {
                    MuiPaper: {
                        styleOverrides: {
                            root: {
                                backgroundColor,
                                color: foregroundColor
                            }
                        }
                    }
                },
                palette: {
                    mode: themeType === "dark" ? "dark" : "light",
                    background: {
                        default: backgroundColor
                    }
                }
            });
        }, [
            themeType
        ]);
        const mixedProps = {
            ...props,
            theme: themeType
        };
        // eslint-disable-next-line react-hooks/exhaustive-deps
        const jsonViewerStore = reactExports.useMemo(()=>createJsonViewerStore(props), []);
        const typeRegistryStore = reactExports.useMemo(()=>createTypeRegistryStore(), []);
        return /*#__PURE__*/ jsxRuntimeExports.jsx(ThemeProvider, {
            theme: theme,
            children: /*#__PURE__*/ jsxRuntimeExports.jsx(TypeRegistryStoreContext.Provider, {
                value: typeRegistryStore,
                children: /*#__PURE__*/ jsxRuntimeExports.jsx(JsonViewerStoreContext.Provider, {
                    value: jsonViewerStore,
                    children: /*#__PURE__*/ jsxRuntimeExports.jsx(JsonViewerInner, {
                        ...mixedProps
                    })
                })
            })
        });
    };

    const getElementFromConfig = (el)=>el ? typeof el === "string" ? document.querySelector(el) : el : document.getElementById("json-viewer");
    class JsonViewer {
        render(el) {
            const container = getElementFromConfig(el);
            if (container) {
                this.root = createRoot(container);
                this.root.render(/*#__PURE__*/ jsxRuntimeExports.jsx(JsonViewer$1, {
                    ...this.props
                }));
            }
        }
        destroy() {
            if (this.root) {
                this.root.unmount();
            }
        }
        constructor(props){
            _define_property(this, "props", void 0);
            _define_property(this, "root", void 0);
            this.props = props;
        }
    }
    _define_property(JsonViewer, "Component", JsonViewer$1);
    _define_property(JsonViewer, "DataTypes", dataTypes);
    _define_property(JsonViewer, "Themes", base16);
    _define_property(JsonViewer, "Utils", {
        applyValue,
        defineDataType,
        deleteValue,
        isCycleReference,
        safeStringify
    });

    return JsonViewer;

}));
