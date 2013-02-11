(function(){var b,a=[].slice;this.valueFn=function(c){return function(){return c}};this.attr=function(c){return function(d){return d[c]}};b=angular.module("kstep",["ng","ngSanitize","ngCookies"]);b.filters=function(e){var d,c;for(c in e){d=e[c];this.filter(c,d)}return this};b.provider({GA:function(){var c;c=[];return{setAccount:function(f,e){var d;if(!e){d=[f,e],e=d[0],f=d[1]}c.push(["_setAccount",e]);if(f){c.push(["_setDomainName",f])}return this},$get:["$window","$location","$jsload","$timeout",function(g,h,d,e){var f;g._gaq=c;f=h.protocol()==="https"?"https://ssl":"http://www";d(f+".google-analytics.com/ga.js");return function(){var i;i=1<=arguments.length?a.call(arguments,0):[];return g._gaq.push(i)}}]}}}).config(["$routeProvider","$locationProvider","$interpolateProvider","$httpProvider","GAProvider",function(g,f,c,e,d){g.when("/",{controller:"BlogCtl",templateUrl:"/partials/list.html"}).when("/tags",{controller:"TagsCtl",templateUrl:"/partials/tags.html"}).when("/tag/:tag",{controller:"TagCtl",templateUrl:"/partials/tag.html"}).when("/:year/:month/:day/:name.html",{controller:"PostCtl",templateUrl:"/partials/post.html"}).when("/:year/:month/:day",{controller:"BlogCtl",templateUrl:"/partials/date.html"}).when("/:year/:month",{controller:"BlogCtl",templateUrl:"/partials/date.html"}).when("/:year",{controller:"BlogCtl",templateUrl:"/partials/date.html"}).otherwise({redirectTo:"/"});f.html5Mode(false);f.hashPrefix("!");c.startSymbol("{:");c.endSymbol(":}");e.responseInterceptors.push(["$rootScope","$q",function(i,h){return function(j){i.$loading=true;return j.then(function(k){i.$loading=false;return k},function(k){i.$loading=false;return h.reject(k)})}}]);return d.setAccount("kstep.me","UA-23938138-1")}]).filters({lpad:function(){return function(d,c,e){d=(d||"").toString();e=e||"0";if(d.length<c){d=(new Array(c-d.length+1).join(e))+d}return d}},rpad:function(){return function(d,c,e){d=(d||"").toString();e=e||"0";if(d.length<c){d=d+(new Array(c-d.length+1).join(e))}return d}},strip_tags:function(){var c;c=/<\/[a-zA-Z][a-zA-Z0-9]*>|<[a-zA-Z][a-zA-Z0-9]*(\s+[^>]*?)?\/?>/g;return function(d){return(d||"").toString().replace(c,"")}},rot13:function(){var d,c;c=/[a-zA-Z]/g;d=function(e){return String.fromCharCode((e<="Z"?90:122)>=(e=e.charCodeAt(0)+13)?e:e-26)};return function(e){return(e||"").toString().replace(c,d)}},asdate:["$filter",function(c){return function(e,d){return c("date")(new Date(e),d)}}],lower:function(){return function(c){return(c||"").toString().toLowerCase()}},upper:function(){return function(c){return(c||"").toString().toUpperCase()}},caps:function(){return function(c){return(c||"").toString().replace(/^./,function(d){return d.toUpperCase()})}},allcaps:function(){return function(c){return(c||"").toString().replace(/\b./g,function(d){return d.toUpperCase()})}}}).directive({ggSearch:["$jsload",function(c){return{restrict:"AE",template:"<gcse:search></gcse:search>",replace:true,compile:function(e,d){return c("//www.google.com/cse.js?cx="+(d.ggSearch||id))}}}],youtube:function(){return{restrict:"AE",scope:true,replace:true,template:'<iframe ng-src="http://www.youtube.com/embed/{: id :}" width="{: width :}" height="{: height :}" frameborder="0" allowfullscreen></iframe>',compile:function(f,d){var c,e,g;g=d.youtube||d.id;e=parseInt(d.width,10)||560;c=parseInt(d.height,10)||315;return function(i,j,h){i.id=g;i.width=e;return i.height=c}}}},totop:["$window",function(c){return{restrict:"AC",compile:function(e,d){var f;f=$(c);f.bind("scroll",function(g){return e.css("display",f.scrollTop()>f.height()/3?"":"none")});e.css("display","none");return function(h,i,g){return i.bind("click",function(){f.scrollTop(0);return i.css("display","none")})}}}}],disqus:["$location","$window","Disqus","$parse",function(g,f,e,d){var c;c=0;return{restrict:"ACE",terminal:true,compile:function(j,i){var k,h;h=i.disqus||i.name;k=i.id;if(!h){return}if(!k){j.attr("id",k="disqus_thread"+c++)}return function(m,n,l){f.disqus_identifier=g.path();f.disqus_url=g.absUrl();f.disqus_container_id=k;f.DISQUS=void 0;n.html("");return e(h)}}}}],ngMeta:["$parse","$interpolate",function(c,d){return{restrict:"EA",terminal:true,compile:function(h,f){var i,g,e;i=c(f.ngMeta||f.name);e=f.value?c(f.value):f.content?d(f.content):h.html()?d(h.html()):null;g=f.update?c(f.update):null;if(!i){return}if(!(e||g)){return}return function(k,l,j){if(e!=null){i.assign(k,e(k))}if(g!=null){return angular.extend(i(k),g(k))}}}}}],calendar:function(){return{restrict:"CEA",controller:"CalendarCtl"}},srcLarge:["$body","$timeout",function(d,c){return{restrict:"A",link:function(f,g,e){return g.bind("click",function(j){var h,k,i;i=angular.element('<div class="modal fade"><div class="modal-body"><img src="'+e.srcLarge+'" /></div></div>');h=angular.element('<div class="modal-backdrop fade"></div>');d.append(h);d.append(i);k=function(){h.removeClass("in");i.removeClass("in");return c(function(){h.remove();return i.remove()})};h.bind("click",k);i.bind("click",k);return c(function(){h.addClass("in");return i.addClass("in")})})}}}],gist:["$http",function(c){return{restrict:"EA",link:function(e,f,d){var g,h;g=d.gist||d.id;if(!g){return}h="https://gist.github.com/"+g+".js";return c.get(h).then(function(i){var j;return f.html([(function(){var n,l,m,k;m=i.data.split("\n");k=[];for(n=0,l=m.length;n<l;n++){j=m[n];k.push(j.substring(16,j.length-2))}return k})()].join(""))})}}}]}).factory({$body:["$document",function(c){return angular.element(c[0].getElementsByTagName("body")[0])}],appcache:["$window","$rootScope",function(f,e){var d,c;d=f.applicationCache||{fakeAppCache:true,UNCACHED:0,IDLE:1,CHECKING:2,DOWNLOADING:3,UPDATEREADY:4,OBSOLETE:5,oncached:null,onchecking:null,ondownloading:null,onnoupdate:null,onobsolete:null,onupdateready:null,status:1,addEventListener:angular.noop,dispatchEvent:angular.noop,removeEventListener:angular.noop,swapCache:angular.noop,update:angular.noop};c={};d.bind=function(g,h){return d.addEventListener(g,c[h]=function(i){h.call(this,i);return e.$apply()},false)};d.unbind=function(g,h){return d.removeEventListener(g,c[h]||h,false)};return d}],$jsload:["$timeout","$q","$document","$rootScope",function(f,e,h,g){var d,c;d={};c={};return function(k,j){var i;if(c[k]){return c[k]}i=e.defer();if(!j&&d[k]){i.resolve(d[k])}else{c[k]=i.promise;if(d[k]){d[k].parentNode.removeChild(d[k]);delete d[k]}f(function(){var l;l=h[0].createElement("script");l.type="text/javascript";l.async=true;l.src=k;l.onerror=function(m){delete c[k];i.reject(l);return g.$digest()};l.onreadystatechange=l.onload=function(m){delete c[k];if(!m.readyState||m.readyState==="loaded"){d[k]=l;i.resolve(l);return g.$digest()}};return h[0].getElementsByTagName("head")[0].appendChild(l)})}return i.promise}}],Pager:function(){return function(d,c,e){this.total_pages=0;this.pages=[];this.set_page=function(g){var f,i,h;f=Math.ceil(d.length/c);if(f!==this.total_pages){this.total_pages=f;this.pages=(function(){h=[];for(var j=1;1<=f?j<=f:j>=f;1<=f?j++:j--){h.push(j)}return h}).apply(this)}this.page=g<1?1:g>f?f:g;this.slice=d.slice((this.page-1)*c,this.page*c);return this};return this.set_page(e)}},Disqus:["$window","$jsload",function(d,c){return function(e){return c("http://"+e+".disqus.com/embed.js",true).then(function(){return d.DISQUS})}}],locales:["$http","$rootScope","$cookies",function(f,e,d){var c;c=function(g){return e.locale=f.get("/i18n/"+g+".json").then(function(h){h.data.lang=g;d.lang=g;return h.data})};c(d.lang||"en");return c}]}).controller({RootCtl:["$scope","$http","locales","appcache","$window","GA","$location","$timeout",function(d,j,c,f,g,i,h,e){f.bind("updateready",function(){d.update_available=true;return f.swapCache()});d.page={};d.locales=c;d.reload_site=function(){return g.location.reload()};d.social_accounts=[{url:"https://twitter.com/kstepme",icon:"http://twitter.com/favicon.ico",name:"Twitter"},{url:"http://www.linkedin.com/pub/konstantin-stepanov/54/47/450",icon:"http://www.linkedin.com/favicon.ico",name:"LinkedIn"},{url:"http://kstepme.moikrug.ru/",icon:"http://moikrug.ru/favicon.ico",name:"Мой Круг"},{url:"http://welinux.ru/user/kstep/",icon:"http://welinux.ru/favicon.ico",name:"WeLinux"},{url:"https://github.com/kstep",icon:"http://github.com/favicon.ico",name:"Github"},{url:"http://www.ohloh.net/accounts/kstep",icon:"http://www.ohloh.net/favicon.ico",name:"Ohloh"},{url:"http://search.cpan.org/~kstepme/",icon:"http://search.cpan.org/favicon.ico",name:"CPAN"}];return d.$on("$routeChangeSuccess",function(){return e(function(){i("_set","title",d.page.title);return i("_trackPageview",h.path())})})}],PostCtl:["$scope","$routeParams",function(d,c){return angular.extend(d.page,{url:"/"+c.year+"/"+c.month+"/"+c.day+"/"+c.name+".html",group:"blog"})}],BlogCtl:["$scope","$routeParams","$http","Pager",function(d,c,g,f){var e;d.$watch("locale.index_title",function(h){return d.page.title=h});angular.extend(d.page,{title:d.locale.index_title,url:"/",group:"blog"});e=(""+(c.year||"")+"-"+(c.month||"")+"-"+(c.day||"")).replace(/-+$/g,"");d.date={year:c.year,month:c.month,day:c.day};return d.pager=g.get("/data/list.json").then(function(h){var j,i;i=e?(function(){var n,l,m,k;m=h.data;k=[];for(n=0,l=m.length;n<l;n++){j=m[n];if(j.date.indexOf(e)!==-1){k.push(j)}}return k})():h.data;return new f(i,40,1)})}],TagCtl:["$scope","$http","$routeParams",function(d,e,c){d.$watch("locale.tag",function(f){return d.page.title=f+" — "+c.tag});angular.extend(d.page,{url:"/tag/"+c.tag,group:"tags"});return e.get("/data/tags.json").success(function(f){d.tag=f[c.tag];return d.tag.name=c.tag})}],TagsCtl:["$scope","$http",function(c,d){c.$watch("locale.tags",function(e){return c.page.title=e});angular.extend(c.page,{url:"/tags",group:"tags"});return d.get("/data/tags.json").success(function(l){var k,i,h,e,m,f,g,j;h=Infinity;i=-Infinity;f=[];for(e in l){m=l[e];if(m.size<h){h=m.size}if(m.size>i){i=m.size}m.name=e;f.push(m)}k=i-h;for(g=0,j=f.length;g<j;g++){m=f[g];m.weight=(m.size-h)/k}return c.tags=f})}],CalendarCtl:["$scope","$element","$attrs","$http",function(m,n,l,j){var h,k,c,d,e,i,o,g,f;k=function(p){p=p==null?new Date:angular.isDate(p)?p:angular.isObject(p)?new Date(p.year,p.month-1,p.day):new Date(p);return{year:p.getFullYear(),month:p.getMonth()+1,day:p.getDate(),dow:p.getDay()}};i=k(new Date);c=function(p){return(p%4===0)&&(p%100!==0||p%400===0)};o=["sun","mon","tue","wed","thu","fri","sat","sun"];d=["december","january","february","march","april","may","june","july","august","september","october","november","december"];m.date=k(l.calendar||l.date||null);m.today=i;m.days=(function(){f=[];for(g=1;g<=31;g++){f.push(g)}return f}).apply(this);h=1;m.weekday=function(p){return o[(h+p-1)%7]};m.is_current=function(p){return m.date.day===p};m.are_equal=function(q,p){return q.year===p.year&&q.month===p.month&&q.day===p.day};m.$watch("date",(function(p){m.date=p=k(p);m.leap_year=c(p.year);m.is_today=p.year===i.year&&p.month===i.month?(function(q){return q===p.day}):(function(q){return false});m.month=d[p.month];return h=(8+p.dow-p.day%7)%7}),true);e={};j.get("/data/list.json").success(function(u){var q,s,t,p,r;r=[];for(t=0,p=u.length;t<p;t++){s=u[t];q=s.date.replace(/-0/g,"-");r.push(e[q]=(e[q]||0)+1)}return r});return m.how_many_posts=function(p){return e[""+m.date.year+"-"+m.date.month+"-"+p]||0}}]})}).call(this);