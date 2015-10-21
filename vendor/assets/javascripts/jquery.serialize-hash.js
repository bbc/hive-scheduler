/*
Copyright (c) 2012 Sébastien Drouyer

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

(function($){
  $.fn.serializeHash = function() {
    var hash = {};
    /***
     JQuery plugin that returns a hash from serialization of any form or dom element. It supports Brackets on input names.
     It is convenient if you want to get values from a form and merge it with an other hash for example.

     ** Added by rilinor on 29/05/2012 : jquery serialize hash now support serialization of any dom elements (before, only form were supported). Thanks !

     Example:
     ---------- HTML ----------
     <form id="form">
       <input type="hidden" name="firstkey" value="val1" />
       <input type="hidden" name="secondkey[0]" value="val2" />
       <input type="hidden" name="secondkey[1]" value="val3" />
       <input type="hidden" name="secondkey[key]" value="val4" />
     </form>
     ---------- JS ----------
     $('#form').serializeHash()
     should return :
     {
       firstkey: 'val1',
       secondkey: {
         0: 'val2',
         1: 'val3',
         key: 'val4'
       }
     }
     ***/
    function stringKey(key, value) {
      var beginBracket = key.lastIndexOf('[');
      if (beginBracket == -1) {
        var hash = {};
        hash[key] = value;
        return hash;
      }
      var newKey = key.substr(0, beginBracket);
      var newValue = {};
      newValue[key.substring(beginBracket + 1, key.length - 1)] = value;
      return stringKey(newKey, newValue);
    }

    var els = $(this).find(':input').get();
    $.each(els, function() {
        if (this.name && !this.disabled && (this.checked || /select|textarea/i.test(this.nodeName) || /hidden|text|search|tel|url|email|password|datetime|date|month|week|time|datetime-local|number|range|color/i.test(this.type))) {
            var val = $(this).val();
            $.extend(true, hash, stringKey(this.name, val));
        }
    });
    return hash;
  };
})(jQuery);
