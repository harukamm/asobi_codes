// 2.7
(function(N){"use strict";var
bT="20",cj=254,b2=224,b_="Sys_error",bS=65535,b1=" < ",ci="Invalid_argument",ch='"',b0=250,ai=1024,cg="jsError",aA="px 'Arial'",bZ="input",bR=785140586,b8=" = ",b9=57343,aB="int_of_string",cf=512,b7=982028505,ce="End_of_file",cd="Failure",bQ="Undefined_recursive_module",a1=256,bY=122,n="t",b6="Cannot happen in insert_rule",bX="Stack_overflow",f="",s=128,bP=56320,ah=100,a2=" : file already exists",b4=240,b5=2048,a=248,bW="Not_found",bN="Assert_failure",bO="/",cb="Sys_blocked_io",cc="fd ",bM="v",b3="Out_of_memory",bV="Match_failure",b$="10",ca="Division_by_zero",o="n",bU=1e3;function
fN(a,b,c,d,e){if(d<=b)for(var
f=1;f<=e;f++)c[d+f]=a[b+f];else
for(var
f=e;f>=1;f--)c[d+f]=a[b+f];return 0}function
a7(a,b,c){var
e=new
Array(c);for(var
d=0;d<c;d++)e[d]=a[b+d];return e}function
a6(a,b,c){var
d=String.fromCharCode;if(b==0&&c<=4096&&c==a.length)return d.apply(null,a);var
e=f;for(;0<c;b+=ai,c-=ai)e+=d.apply(null,a7(a,b,Math.min(c,ai)));return e}function
cm(a){var
c=new
Array(a.l),e=a.c,d=e.length,b=0;for(;b<d;b++)c[b]=e.charCodeAt(b);for(d=a.l;b<d;b++)c[b]=0;a.c=c;a.t=4;return c}function
Y(a,b,c,d,e){if(e==0)return 0;if(d==0&&(e>=c.l||c.t==2&&e>=c.c.length)){c.c=a.t==4?a6(a.c,b,e):b==0&&a.c.length==e?a.c:a.c.substr(b,e);c.t=c.c.length==c.l?0:2}else
if(c.t==2&&d==c.c.length){c.c+=a.t==4?a6(a.c,b,e):b==0&&a.c.length==e?a.c:a.c.substr(b,e);c.t=c.c.length==c.l?0:2}else{if(c.t!=4)cm(c);var
g=a.c,h=c.c;if(a.t==4)for(var
f=0;f<e;f++)h[d+f]=g[b+f];else{var
i=Math.min(e,g.length-b);for(var
f=0;f<i;f++)h[d+f]=g.charCodeAt(b+f);for(;f<e;f++)h[d+f]=0}}return 0}function
gi(a,b){var
e=a.length,d=new
Array(e+1),c=0;for(;c<e;c++)d[c]=a[c];d[c]=b;return d}function
Z(c,b){if(c.fun)return Z(c.fun,b);var
a=c.length,d=b.length,e=a-d;if(e==0)return c.apply(null,b);else
if(e<0)return Z(c.apply(null,a7(b,0,a)),a7(b,a,d-a));else
return function(a){return Z(c,gi(b,a))}}function
f7(a,b){throw[0,a,b]}function
f_(a,b){if(b.repeat)return b.repeat(a);var
c=f,d=0;if(a==0)return c;for(;;){if(a&1)c+=b;a>>=1;if(a==0)return c;b+=b;d++;if(d==9)b.slice(0,1)}}function
_(a){if(a.t==2)a.c+=f_(a.l-a.c.length,"\0");else
a.c=a6(a.c,0,a.c.length);a.t=0}function
cn(a){if(a.length<24){for(var
b=0;b<a.length;b++)if(a.charCodeAt(b)>127)return false;return true}else
return!/[^\x00-\x7f]/.test(a)}function
ge(a){for(var
k=f,d=f,h,g,i,b,c=0,j=a.length;c<j;c++){g=a.charCodeAt(c);if(g<s){for(var
e=c+1;e<j&&(g=a.charCodeAt(e))<s;e++);if(e-c>cf){d.substr(0,1);k+=d;d=f;k+=a.slice(c,e)}else
d+=a.slice(c,e);if(e==j)break;c=e}b=1;if(++c<j&&((i=a.charCodeAt(c))&-64)==s){h=i+(g<<6);if(g<b2){b=h-12416;if(b<s)b=1}else{b=2;if(++c<j&&((i=a.charCodeAt(c))&-64)==s){h=i+(h<<6);if(g<b4){b=h-925824;if(b<b5||b>=55295&&b<57344)b=2}else{b=3;if(++c<j&&((i=a.charCodeAt(c))&-64)==s&&g<245){b=i-63447168+(h<<6);if(b<65536||b>1114111)b=3}}}}}if(b<4){c-=b;d+="\ufffd"}else
if(b>bS)d+=String.fromCharCode(55232+(b>>10),bP+(b&1023));else
d+=String.fromCharCode(b);if(d.length>ai){d.substr(0,1);k+=d;d=f}}return k+d}function
gd(a){switch(a.t){case
9:return a.c;default:_(a);case
0:if(cn(a.c)){a.t=9;return a.c}a.t=8;case
8:return ge(a.c)}}function
w(a,b,c){this.t=a;this.c=b;this.l=c}w.prototype.toString=function(){return gd(this)};function
d(a){return new
w(0,a,a.length)}function
a4(a,b){f7(a,d(b))}var
p=[0];function
aD(a){a4(p.Invalid_argument,a)}function
fO(){aD("index out of bounds")}function
aC(a,b){if(b>>>0>=a.length-1)fO();return a}function
fU(a,b){var
c=a[3]<<16,d=b[3]<<16;if(c>d)return 1;if(c<d)return-1;if(a[2]>b[2])return 1;if(a[2]<b[2])return-1;if(a[1]>b[1])return 1;if(a[1]<b[1])return-1;return 0}function
fV(a,b){if(a<b)return-1;if(a==b)return 0;return 1}function
f$(a,b){a.t&6&&_(a);b.t&6&&_(b);return a.c<b.c?-1:a.c>b.c?1:0}function
cl(a,b,c){var
e=[];for(;;){if(!(c&&a===b))if(a
instanceof
w)if(b
instanceof
w){if(a!==b){var
d=f$(a,b);if(d!=0)return d}}else
return 1;else
if(a
instanceof
Array&&a[0]===(a[0]|0)){var
f=a[0];if(f===cj)f=0;if(f===b0){a=a[1];continue}else
if(b
instanceof
Array&&b[0]===(b[0]|0)){var
g=b[0];if(g===cj)g=0;if(g===b0){b=b[1];continue}else
if(f!=g)return f<g?-1:1;else
switch(f){case
248:var
d=fV(a[2],b[2]);if(d!=0)return d;break;case
251:aD("equal: abstract value");case
255:var
d=fU(a,b);if(d!=0)return d;break;default:if(a.length!=b.length)return a.length<b.length?-1:1;if(a.length>1)e.push(a,b,1)}}else
return 1}else
if(b
instanceof
w||b
instanceof
Array&&b[0]===(b[0]|0))return-1;else
if(typeof
a!="number"&&a&&a.compare)return a.compare(b,c);else{if(a<b)return-1;if(a>b)return 1;if(a!=b){if(!c)return NaN;if(a==a)return 1;if(b==b)return-1}}if(e.length==0)return 0;var
h=e.pop();b=e.pop();a=e.pop();if(h+1<a.length)e.push(a,b,h+1);a=a[h];b=b[h]}}function
fQ(a,b){return cl(a,b,true)}function
H(a){if(a<0)aD("String.create");return new
w(a?2:9,f,a)}function
fT(a,b){return+(cl(a,b,false)>=0)}function
ak(a,b){switch(a.t&6){default:if(b>=a.c.length)return 0;case
0:return a.c.charCodeAt(b);case
4:return a.c[b]}}function
A(a){return a.l}function
f6(a){var
b=0,d=A(a),c=10,e=d>0&&ak(a,0)==45?(b++,-1):1;if(b+1<d&&ak(a,b)==48)switch(ak(a,b+1)){case
120:case
88:c=16;b+=2;break;case
111:case
79:c=8;b+=2;break;case
98:case
66:c=2;b+=2;break}return[b,e,c]}function
cs(a){if(a>=48&&a<=57)return a-48;if(a>=65&&a<=90)return a-55;if(a>=97&&a<=bY)return a-87;return-1}function
aj(a){a4(p.Failure,a)}function
fW(a){var
h=f6(a),d=h[0],i=h[1],e=h[2],g=A(a),j=-1>>>0,f=d<g?ak(a,d):0,c=cs(f);if(c<0||c>=e)aj(aB);var
b=c;for(d++;d<g;d++){f=ak(a,d);if(f==95)continue;c=cs(f);if(c<0||c>=e)break;b=e*b+c;if(b>j)aj(aB)}if(d!=g)aj(aB);b=i*b;if(e==10&&(b|0)!=b)aj(aB);return b|0}var
aE={amp:/&/g,lt:/</g,quot:/\"/g,all:/[&<\"]/};function
co(a){if(!aE.all.test(a))return a;return a.replace(aE.amp,"&amp;").replace(aE.lt,"&lt;").replace(aE.quot,"&quot;")}function
gf(a){for(var
g=f,c=g,b,i,d=0,h=a.length;d<h;d++){b=a.charCodeAt(d);if(b<s){for(var
e=d+1;e<h&&(b=a.charCodeAt(e))<s;e++);if(e-d>cf){c.substr(0,1);g+=c;c=f;g+=a.slice(d,e)}else
c+=a.slice(d,e);if(e==h)break;d=e}if(b<b5){c+=String.fromCharCode(192|b>>6);c+=String.fromCharCode(s|b&63)}else
if(b<55296||b>=b9)c+=String.fromCharCode(b2|b>>12,s|b>>6&63,s|b&63);else
if(b>=56319||d+1==h||(i=a.charCodeAt(d+1))<bP||i>b9)c+="\xef\xbf\xbd";else{d++;b=(b<<10)+i-56613888;c+=String.fromCharCode(b4|b>>18,s|b>>12&63,s|b>>6&63,s|b&63)}if(c.length>ai){c.substr(0,1);g+=c;c=f}}return g+c}function
aF(a){var
b=9;if(!cn(a))b=8,a=gf(a);return new
w(b,a,a.length)}function
ck(a){if((a.t&6)!=0)_(a);return a.c}function
t(a){a=ck(a);var
d=a.length/2,c=new
Array(d);for(var
b=0;b<d;b++)c[b]=(a.charCodeAt(2*b)|a.charCodeAt(2*b+1)<<8)<<16>>16;return c}function
fP(a){if(a.t!=4)cm(a);return a.c}function
fX(a,b,c){var
o=2,p=3,s=5,e=6,i=7,h=8,k=9,n=1,m=2,r=3,u=4,q=5;if(!a.lex_default){a.lex_base=t(a[n]);a.lex_backtrk=t(a[m]);a.lex_check=t(a[q]);a.lex_trans=t(a[u]);a.lex_default=t(a[r])}var
f,d=b,l=fP(c[o]);if(d>=0){c[i]=c[s]=c[e];c[h]=-1}else
d=-d-1;for(;;){var
g=a.lex_base[d];if(g<0)return-g-1;var
j=a.lex_backtrk[d];if(j>=0){c[i]=c[e];c[h]=j}if(c[e]>=c[p])if(c[k]==0)return-d-1;else
f=a1;else{f=l[c[e]];c[e]++}d=a.lex_check[g+f]==d?a.lex_trans[g+f]:a.lex_default[d];if(d<0){c[e]=c[i];if(c[h]==-1)aj("lexing: empty token");else
return c[h]}else
if(f==a1)c[k]=0}}function
M(a,b){var
a=a+1|0,c=new
Array(a);c[0]=0;for(var
d=1;d<a;d++)c[d]=b;return c}function
B(a){a4(p.Sys_error,a)}function
fY(a){if(!a.opened)B("Cannot flush a closed channel");if(a.buffer==f)return 0;if(a.output)switch(a.output.length){case
2:a.output(a,a.buffer);break;default:a.output(a.buffer)}a.buffer=f;return 0}var
cv=0;function
gj(){return new
Date().getTime()/bU}function
a8(){return Math.floor(gj())}function
L(a){this.data=a;this.inode=cv++;var
b=a8();this.atime=b;this.mtime=b;this.ctime=b}L.prototype={truncate:function(){this.data=H(0);this.modified()},modified:function(){var
a=a8();this.atime=a;this.mtime=a}};function
ct(a){a=a
instanceof
w?a.toString():a;B(a+": No such file or directory")}var
fR=bO;function
aG(a){a=a
instanceof
w?a.toString():a;if(a.charCodeAt(0)!=47)a=fR+a;var
d=a.split(bO),b=[];for(var
c=0;c<d.length;c++)switch(d[c]){case"..":if(b.length>1)b.pop();break;case".":break;case"":if(b.length==0)b.push(f);break;default:b.push(d[c]);break}b.orig=a;return b}function
U(){this.content={};this.inode=cv++;var
a=a8();this.atime=a;this.mtime=a;this.ctime=a}U.prototype={exists:function(a){return this.content[a]?1:0},mk:function(a,b){this.content[a]=b},get:function(a){return this.content[a]},list:function(){var
a=[];for(var
b
in
this.content)a.push(b);return a},remove:function(a){delete
this.content[a]}};var
aI=new
U();aI.mk(f,new
U());function
a3(a){var
b=aI;for(var
c=0;c<a.length;c++){if(!(b.exists&&b.exists(a[c])))ct(a.orig);b=b.get(a[c])}return b}function
gc(a){var
c=aG(a),b=a3(c);return b
instanceof
U?1:0}function
ga(a){return new
w(4,a,a.length)}function
fS(a,b){var
f=aG(a),c=aI;for(var
g=0;g<f.length-1;g++){var
e=f[g];if(!c.exists(e))c.mk(e,new
U());c=c.get(e);if(!(c
instanceof
U))B(f.orig+a2)}var
e=f[f.length-1];if(c.exists(e))B(f.orig+a2);if(b
instanceof
U)c.mk(e,b);else
if(b
instanceof
L)c.mk(e,b);else
if(b
instanceof
w)c.mk(e,new
L(b));else
if(b
instanceof
Array)c.mk(e,new
L(ga(b)));else
if(b.toString)c.mk(e,new
L(d(b.toString())));else
aD("caml_fs_register");return 0}function
gb(a){var
b=aI,d=aG(a),e,f;for(var
c=0;c<d.length;c++){if(b.auto){e=b.auto;f=c}if(!(b.exists&&b.exists(d[c])))return e?e(d,f):0;b=b.get(d[c])}return 1}function
al(a,b,c){if(p.fds===undefined)p.fds=new
Array();c=c?c:{};var
d={};d.file=b;d.offset=c.append?A(b.data):0;d.flags=c;p.fds[a]=d;p.fd_last_idx=a;return a}function
gk(a,b,c){var
d={};while(b){switch(b[1]){case
0:d.rdonly=1;break;case
1:d.wronly=1;break;case
2:d.append=1;break;case
3:d.create=1;break;case
4:d.truncate=1;break;case
5:d.excl=1;break;case
6:d.binary=1;break;case
7:d.text=1;break;case
8:d.nonblock=1;break}b=b[2]}var
f=a.toString(),h=aG(a);if(d.rdonly&&d.wronly)B(f+" : flags Open_rdonly and Open_wronly are not compatible");if(d.text&&d.binary)B(f+" : flags Open_text and Open_binary are not compatible");if(gb(a)){if(gc(a))B(f+" : is a directory");if(d.create&&d.excl)B(f+a2);var
g=p.fd_last_idx?p.fd_last_idx:0,e=a3(h);if(d.truncate)e.truncate();return al(g+1,e,d)}else
if(d.create){var
g=p.fd_last_idx?p.fd_last_idx:0;fS(a,H(0));var
e=a3(h);return al(g+1,e,d)}else
ct(a)}al(0,new
L(H(0)));al(1,new
L(H(0)));al(2,new
L(H(0)));function
fZ(a){var
b=p.fds[a];if(b.flags.wronly)B(cc+a+" is writeonly");return{file:b.file,offset:b.offset,fd:a,opened:true,refill:null}}function
gg(a){if(a.charCodeAt(a.length-1)==10)a=a.substr(0,a.length-1);var
b=N.console;b&&b.error&&b.error(a)}function
gh(a){if(a.charCodeAt(a.length-1)==10)a=a.substr(0,a.length-1);var
b=N.console;b&&b.log&&b.log(a)}var
aH=new
Array();function
f9(a,b){var
h=d(b),c=A(h),g=A(a.file.data),f=a.offset;if(f+c>=g){var
e=H(f+c);Y(a.file.data,0,e,0,g);Y(h,0,e,f,c);a.file.data=e}a.offset+=c;a.file.modified();return 0}function
cp(a){var
b;switch(a){case
1:b=gh;break;case
2:b=gg;break;default:b=f9}var
d=p.fds[a];if(d.flags.rdonly)B(cc+a+" is readonly");var
c={file:d.file,offset:d.offset,fd:a,opened:true,buffer:f,output:b};aH[c.fd]=c;return c}function
f0(){var
a=0;for(var
b
in
aH)if(aH[b].opened)a=[0,aH[b],a];return a}if(!Math.imul)Math.imul=function(a,b){b|=0;return((a>>16)*b<<16)+(a&bS)*b|0};var
f1=Math.imul;function
f3(a){return+(a
instanceof
Array)}function
cr(a){return a
instanceof
Array?a[0]:a
instanceof
w?252:bU}function
f5(a,b,c,d){var
w=a1,v=6,aa=7,P=8,Q=9,E=10,J=0,r=1,H=2,I=3,G=4,F=5,o=1,D=2,C=3,p=4,A=5,M=6,h=7,u=8,O=9,N=10,x=11,K=12,L=13,z=14,B=15,y=16,$=2,_=3,W=4,V=5,S=6,T=7,Y=8,X=9,U=10,q=11,Z=12,R=13;if(!a.dgoto){a.defred=t(a[S]);a.sindex=t(a[Y]);a.check=t(a[R]);a.rindex=t(a[X]);a.table=t(a[Z]);a.len=t(a[V]);a.lhs=t(a[W]);a.gindex=t(a[U]);a.dgoto=t(a[T])}var
l=0,k,g,f,n,e=b[z],i=b[B],j=b[y];exit:for(;;)switch(c){case
0:i=0;j=0;case
6:k=a.defred[i];if(k!=0){c=E;break}if(b[h]>=0){c=aa;break}l=J;break exit;case
1:if(d
instanceof
Array){b[h]=a[_][d[0]+1];b[u]=d[1]}else{b[h]=a[$][d+1];b[u]=0}case
7:g=a.sindex[i];f=g+b[h];if(g!=0&&f>=0&&f<=a[q]&&a.check[f]==b[h]){c=P;break}g=a.rindex[i];f=g+b[h];if(g!=0&&f>=0&&f<=a[q]&&a.check[f]==b[h]){k=a.table[f];c=E;break}if(j<=0){l=F;break exit}case
5:if(j<3){j=3;for(;;){n=b[o][e+1];g=a.sindex[n];f=g+w;if(g!=0&&f>=0&&f<=a[q]&&a.check[f]==w){c=Q;break}else{if(e<=b[M])return r;e--}}}else{if(b[h]==0)return r;b[h]=-1;c=v;break}case
8:b[h]=-1;if(j>0)j--;case
9:i=a.table[f];e++;if(e>=b[A]){l=H;break exit}case
2:b[o][e+1]=i;b[D][e+1]=b[u];b[C][e+1]=b[O];b[p][e+1]=b[N];c=v;break;case
10:var
m=a.len[k];b[x]=e;b[L]=k;b[K]=m;e=e-m+1;m=a.lhs[k];n=b[o][e];g=a.gindex[m];f=g+n;i=g!=0&&f>=0&&f<=a[q]&&a.check[f]==n?a.table[f]:a.dgoto[m];if(e>=b[A]){l=I;break exit}case
3:l=G;break exit;case
4:b[o][e+1]=i;b[D][e+1]=d;var
s=b[x];b[p][e+1]=b[p][s+1];if(e>s)b[C][e+1]=b[p][s+1];c=v;break;default:return r}b[z]=e;b[B]=i;b[y]=j;return l}function
x(a,b,c){p[a+1]=b;if(c)p[c]=b}var
cq={};function
f8(a,b){cq[ck(a)]=b;return 0}var
f4=0;function
C(a){a[2]=f4++;return a}function
a5(a,b){a.t&6&&_(a);b.t&6&&_(b);return a.c==b.c?1:0}function
cu(a){return a}function
f2(a){return cq[a]}function
$(a){if(a
instanceof
Array)return a;if(N.RangeError&&a
instanceof
N.RangeError&&a.message&&a.message.match(/maximum call stack/i))return cu(p.Stack_overflow);if(N.InternalError&&a
instanceof
N.InternalError&&a.message&&a.message.match(/too much recursion/i))return cu(p.Stack_overflow);if(a
instanceof
N.Error)return[0,f2(cg),a];return[0,p.Failure,aF(String(a))]}function
e(a,b){return a.length==1?a(b):Z(a,[b])}function
i(a,b,c){return a.length==2?a(b,c):Z(a,[b,c])}function
fM(a,b,c,d){return a.length==3?a(b,c,d):Z(a,[b,c,d])}var
a_=[a,d(cd),-3],a9=[a,d(ci),-4],ap=[a,d(bW),-7],a$=[a,d(bN),-11],V=[0,d(f),0,0,-1],bb=[0,d(f),1,0,0],aP=d("#FFFFFF"),bB=[0,-1,-1];x(11,[a,d(bQ),-12],bQ);x(10,a$,bN);x(9,[a,d(cb),-10],cb);x(8,[a,d(bX),-9],bX);x(7,[a,d(bV),-8],bV);x(6,ap,bW);x(5,[a,d(ca),-6],ca);x(4,[a,d(ce),-5],ce);x(3,a9,ci);x(2,a_,cd);x(1,[a,d(b_),-2],b_);x(0,[a,d(b3),-1],b3);var
cw=d("Pervasives.Exit"),cy=d("Array.blit"),cz=d("Array.Bottom"),cA=d("List.map2"),cB=d("String.sub / Bytes.sub"),cC=d("Sys.Break"),cH=d("syntax error"),cD=d("Parsing.YYexit"),cE=d("Parsing.Parse_error"),cJ=d("CamlinternalFormat.Type_mismatch"),cN=d("Js.Error"),cU=d("canvas"),cR=d("br"),cQ=d("textarea"),cP=d(bZ),cS=d("Dom_html.Canvas_not_available"),cW=d("_"),cX=d("0"),c5=d("\n"),c4=[0,d("html.ml"),109,17],c3=d(aA),c2=d(aA),c1=d(aA),c0=d(aA),cZ=d("#55FF55"),c9=d("code cannot be unified"),c8=d(f),c6=d("Fix.Cannot_take"),c7=d("Fix.Unify_Error"),c$=d(f),dc=d(b6),dd=d(b6),dm=d("go"),dn=d("delete"),dp=d(f),dk=d(" "),dj=d("\xe9\x81\xa9\xe7\x94\xa8\xe5\x8f\xaf\xe8\x83\xbd\xe8\xa6\x8f\xe5\x89\x87\xef\xbc\x9a"),di=d(f),dg=d(f),de=d(f),df=d(f),da=d(f),db=d(f),c_=[0,d(f),[0,0,0,0,0]],d2=d(b1),d3=d(" >= "),d4=d(b8),d5=d(" <> "),eP=d(n),eQ=d(n),eR=d(n),eS=d(bM),eL=d(n),eM=d(n),eN=d(n),eO=d(bM),eG=d(n),eH=d(n),eI=d(o),eJ=d(o),eB=d(n),eC=d(n),eD=d(o),eE=d(o),ew=d(n),ex=d(n),ey=d(o),ez=d(o),er=d(n),es=d(n),et=d(o),eu=d(o),el=d(n),em=d(n),en=d(o),eo=d(o),ep=d(o),ef=d(n),eg=d(n),eh=d(o),ei=d(o),ej=d(o),d$=d(n),ea=d(n),eb=d(o),ec=d(o),ed=d(o),d9=d("b"),d7=d(o),d1=d("*"),d0=d("-"),dZ=d("+"),dY=d(" \xe2\x86\x93 "),dX=d("of eval"),dI=d(" + "),dJ=d(" - "),dK=d(" * "),dL=d(b8),dM=d(" != "),dN=d(b1),dO=d(" !< "),dP=d(" else "),dQ=d(" then "),dR=d("if "),dH=d("of Exp"),dD=d("of value"),dz=d("false"),dy=d("true"),dx=d("of Bool"),dt=d("of Int"),eU=d("EIfFalse"),eV=d("EIfTrue"),eW=d("ELessFalse"),eX=d("ELessTrue"),eY=d("EEqFalse"),eZ=d("EEqTrue"),e0=d("ETimes"),e1=d("EMinus"),e2=d("EPlus"),e3=d("EBool"),e4=d("ENum"),fE=d("parser"),e5=[0,257,258,259,260,261,262,263,265,266,267,268,269,270,271,0],e8=d("\xff\xff\x01\0\x03\0\x03\0\x03\0\x04\0\x04\0\x04\0\x05\0\x05\0\x05\0\x06\0\x06\0\x06\0\x06\0\x06\0\x06\0\x06\0\x06\0\x06\0\x06\0\x02\0\0\0"),e9=d("\x02\0\x02\0\x02\0\x01\0\x03\0\x01\0\x01\0\x03\0\x01\0\x01\0\x03\0\x01\0\x01\0\x03\0\x03\0\x03\0\x03\0\x03\0\x06\0\x02\0\x03\0\x03\0\x02\0"),e_=d("\0\0\0\0\0\0\0\0\0\0\x03\0\x05\0\x06\0\0\0\x16\0\0\0\x0b\0\f\0\0\0\0\0\0\0\0\0\x02\0\x13\0\0\0\x01\0\0\0\0\0\0\0\0\0\0\0\0\0\x04\0\x07\0\x14\0\0\0\0\0\0\0\x0f\0\0\0\0\0\0\0\0\0\b\0\t\0\x15\0\0\0\0\0\0\0\0\0\x02\0\0\0\n\0\0\0"),e$=d("\x02\0\t\0\n\0\x0b\0\f\0(\0\r\0"),fa=d("\x0f\0\x16\xff\0\0\x16\xffH\xff\0\0\0\0\0\0\x16\xff\0\0\xf5\xfe\0\0\0\0A\xff\x1a\xff \xffa\xff\0\0\0\0\x05\xff\0\0\x16\xff\x16\xff\x16\xff\x16\xff\x16\xffX\xff\0\0\0\0\0\0\x16\xff\x13\xff\x13\xff\0\0p\xffu\xffX\xff$\xff\0\0\0\0\0\0Q\xff\x1a\xff \xff(\xff\0\0\x16\xff\0\0p\xff"),fb=d('\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0f\xffk\xff\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"\xff/\xff\0\x005\xff\x01\xff\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x002\xff'),fc=d("\0\0\0\0\0\0\xff\xff\x03\0\t\0\xfd\xff"),fe=d("\x10\0\x12\0\x0e\0\x11\0\x14\0\x13\0\x0f\0\x11\0\x15\0\x16\0\x17\0\x18\0\x19\0\x11\0\x11\0\x11\0\x01\0\x1e\0\x1f\0 \0!\0\"\0#\0\x03\0\x17\0&\0\x04\0)\0\x1b\0'\0\x05\0\x06\0\x07\0\b\0\x1c\0*\0\r\0\r\0\r\0+\0\r\0\r\0/\x000\0-\0,\0\r\0\r\0\r\0\x0e\0\x0e\0\x0e\0\x12\0\x0e\0\x0e\0\x10\0\x12\0\0\0\0\0\x0e\0\x0e\0\x0e\0\x12\0\x12\0\x12\0\x10\0\x10\0\x10\0\x15\0\x16\0\x17\0\x18\0\x19\0\x03\0\0\0\0\0\x04\0\0\0\0\0\x1a\0\x11\0\x06\0\x07\0\b\0\x15\0\x16\0\x17\0\x18\0\x19\0$\0\0\0\0\0%\0\0\0.\0\0\0\x05\0\x06\0\x07\0\x1d\0\x15\0\x16\0\x17\0\x18\0\x19\0\x0b\0\x0b\0\x0b\0\x0b\0\x0b\0\f\0\f\0\f\0\f\0\f\0\x15\0\x16\0\x17\0\0\0\x19\0\x15\0\x16\0\x17\0"),ff=d("\x03\0\x04\0\x03\0\x02\x01\x0f\x01\b\0\x03\0\x06\x01\x03\x01\x04\x01\x05\x01\x06\x01\x07\x01\f\x01\r\x01\x0e\x01\x01\0\f\x01\x15\0\x16\0\x17\0\x18\0\x19\0\x01\x01\x05\x01\x1a\0\x04\x01\x1e\0\x02\x01\x1a\0\b\x01\t\x01\n\x01\x0b\x01\x02\x01$\0\x02\x01\x03\x01\x04\x01$\0\x06\x01\x07\x01\x02\x01.\0\b\x01$\0\f\x01\r\x01\x0e\x01\x02\x01\x03\x01\x04\x01\x02\x01\x06\x01\x07\x01\x02\x01\x06\x01\xff\xff\xff\xff\f\x01\r\x01\x0e\x01\f\x01\r\x01\x0e\x01\f\x01\r\x01\x0e\x01\x03\x01\x04\x01\x05\x01\x06\x01\x07\x01\x01\x01\xff\xff\xff\xff\x04\x01\xff\xff\xff\xff\x0e\x01\b\x01\t\x01\n\x01\x0b\x01\x03\x01\x04\x01\x05\x01\x06\x01\x07\x01\x01\x01\xff\xff\xff\xff\x04\x01\xff\xff\r\x01\xff\xff\b\x01\t\x01\n\x01\x02\x01\x03\x01\x04\x01\x05\x01\x06\x01\x07\x01\x03\x01\x04\x01\x05\x01\x06\x01\x07\x01\x03\x01\x04\x01\x05\x01\x06\x01\x07\x01\x03\x01\x04\x01\x05\x01\xff\xff\x07\x01\x03\x01\x04\x01\x05\x01"),fg=d("LPAREN\0RPAREN\0PLUS\0MINUS\0TIMES\0EQUAL\0LESS\0TRUE\0FALSE\0IF\0THEN\0ELSE\0TO\0EOI\0"),fh=d("NUMBER\0"),fI=d("unknown token "),fG=[0,d("\0\0\xee\xff\x03\0\0\0\x01\0\x0f\0\0\0\0\0\xf7\xff\xf8\xff\xf9\xff\xfa\xff\xfb\xff\xfc\xff\x02\0\x01\0\x01\0\xfe\xff\xf0\xff\x05\0\0\0\x06\0\xf6\xff\0\0\xf2\xff\x01\0\0\0\x0b\0\xf5\xff\xf3\xff\x03\0\f\0\xf1\xff\xef\xff"),d("\xff\xff\xff\xff\x11\0\x11\0\x11\0\x0b\0\x11\0\x11\0\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\x02\0\0\0\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"),d("\x01\0\0\0\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0\0\xff\xff\xff\xff\x10\0\0\0\0\0\xff\xff\xff\xff\xff\xff\0\0\xff\xff\0\0\xff\xff\xff\xff\xff\xff\0\0\0\0\xff\xff\xff\xff\0\0\0\0"),d("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x0f\0\x0f\0\x11\0\0\0\x0f\0\x0f\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x0f\0\x0f\0\0\0\0\0\0\0\0\0\0\0\0\0\x0e\0\r\0\n\0\f\0\x10\0\x0b\0\0\0\0\0\x05\0\x05\0\x05\0\x05\0\x05\0\x05\0\x05\0\x05\0\x05\0\x05\0\0\0\x02\0\b\0\t\0!\0\x05\0\x05\0\x05\0\x05\0\x05\0\x05\0\x05\0\x05\0\x05\0\x05\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x19\0\0\0\0\0\0\0\x03\0\x06\0\x1d\0\x13\0\x04\0\x17\0\x16\0\x1e\0\x1a\0\x18\0\x12\0\x1c\0 \0\x14\0\x1b\0\x07\0\x15\0\x1f\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"),d("\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\0\0\x0f\0\x10\0\xff\xff\0\0\x0f\0\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\0\0\x0f\0\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\0\0\0\0\0\0\0\0\x0e\0\0\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\xff\xff\0\0\0\0\0\0\x02\0\x05\0\x05\0\x05\0\x05\0\x05\0\x05\0\x05\0\x05\0\x05\0\x05\0\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\x06\0\xff\xff\xff\xff\xff\xff\0\0\0\0\x04\0\x07\0\0\0\x13\0\x15\0\x03\0\x19\0\x17\0\x07\0\x1b\0\x1f\0\x07\0\x1a\0\0\0\x14\0\x1e\0\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\0\0\x10\0\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"),d(f),d(f),d(f),d(f),d(f),d(f)],fL=d(";;");function
am(a){throw[0,a_,a]}function
aJ(a){throw[0,a9,a]}C([a,cw,0]);function
aa(a,b){return fT(a,b)?a:b}function
D(a,b){var
c=A(a),e=A(b),d=H(c+e|0);Y(a,0,d,0,c);Y(b,0,d,c,e);return d}fZ(0);cp(1);cp(2);function
an(a,b,c,d,e){if(0<=e)if(0<=b)if(!((a.length-1-e|0)<b))if(0<=d)if(!((c.length-1-e|0)<d))return fN(a,b,c,d,e);return aJ(cy)}C([a,cz,0]);function
E(a,b){if(b){var
c=b[2],d=e(a,b[1]);return[0,d,E(a,c)]}return 0}function
ao(a,b){var
c=b;for(;;){if(c){var
d=c[2];e(a,c[1]);var
c=d;continue}return 0}}function
aK(a,b,c){if(b){if(c){var
d=c[2],e=b[2],f=i(a,b[1],c[1]);return[0,f,aK(a,e,d)]}}else
if(!c)return 0;return aJ(cA)}function
ba(a,b){var
c=b;for(;;){if(c){var
d=c[1],e=c[2],f=d[2];if(0===fQ(d[1],a))return f;var
c=e;continue}throw ap}}C([a,cC,0]);function
bc(a){var
b=a[6]-a[5]|0,c=a[5],e=a[2];if(0<=c)if(0<=b)if(!((A(e)-b|0)<c)){var
d=H(b);Y(e,c,d,0,b);return d}return aJ(cB)}var
bd=C([a,cD,0]),be=C([a,cE,0]),j=[0,M(ah,0),M(ah,0),M(ah,V),M(ah,V),ah,0,0,0,V,V,0,0,0,0,0,0];function
bf(a){var
b=j[5],c=b*2|0,d=M(c,0),e=M(c,0),f=M(c,V),g=M(c,V);an(j[1],0,d,0,b);j[1]=d;an(j[2],0,e,0,b);j[2]=e;an(j[3],0,f,0,b);j[3]=f;an(j[4],0,g,0,b);j[4]=g;j[5]=c;return 0}var
cF=[0,function(a){return 0}];function
cG(g,b,c,d){var
n=j[11],o=j[14],p=j[6],q=j[15],r=j[7],s=j[8],t=j[16];j[6]=j[14]+1|0;j[7]=b;j[10]=d[12];try{var
f=0,a=0;for(;;)switch(f5(g,j,f,a)){case
0:var
l=e(c,d);j[9]=d[11];j[10]=d[12];var
f=1,a=l;continue;case
1:throw be;case
2:bf(0);var
f=2,a=0;continue;case
3:bf(0);var
f=3,a=0;continue;case
4:try{var
i=j[13],m=[0,4,e(aC(g[1],i)[i+1],j)],h=m}catch(f){f=$(f);if(f!==be)throw f;var
h=[0,5,0]}var
f=h[1],a=h[2];continue;default:e(g[14],cH);var
f=5,a=0;continue}}catch(f){f=$(f);var
k=j[7];j[11]=n;j[14]=o;j[6]=p;j[15]=q;j[7]=r;j[8]=s;j[16]=t;if(f[1]===bd)return f[2];cF[1]=function(a){if(f3(a)){var
b=cr(a);return aC(g[3],b)[b+1]===k?1:0}return aC(g[2],a)[a+1]===k?1:0};throw f}}function
b(a,b){var
c=a[11]-b|0;return aC(a[2],c)[c+1]}function
cI(a){return 0}C([a,cJ,0]);var
bg=[0,0];function
bh(a){bg[1]=[0,a,bg[1]];return 0}var
ab=N,bi=null,cL=undefined;function
bj(a){return 1-(a==bi?1:0)}var
aq=false,bk=ab.Array,bl=C([a,cN,0]),aL=[0,bl,{}],cM=true,cK=cr(aL)===a?aL:aL[1];f8(d(cg),cK);bh(function(a){return a[1]===bl?[0,aF(a[2].toString())]:0});bh(function(a){return a
instanceof
bk?0:[0,aF(a.toString())]});function
F(a,b){a.appendChild(b);return 0}function
aM(c){return function(a){if(bj(a)){var
d=e(c,a);if(!(d|0))a.preventDefault();return d}var
f=event,b=e(c,f);if(!(b|0))f.returnValue=b;return b}}var
O="2d",cO=ab.document;function
ar(a,b){return a?e(b,a[1]):0}function
aN(a,b){return a.createElement(b.toString())}function
bm(a,b){return aN(a,b)}var
bn=[0,bR];function
bo(a,b,c,d){for(;;){if(0===a)if(0===b)return aN(c,d);var
h=bn[1];if(bR===h){try{var
j=cO.createElement('<input name="x">'),k=j.tagName.toLowerCase()===bZ?1:0,m=k?j.name==="x"?1:0:k,i=m}catch(f){var
i=0}var
l=i?b7:-1003883683;bn[1]=l;continue}if(b7<=h){var
e=new
bk();e.push("<",d.toString());ar(a,function(a){e.push(' type="',co(a),ch);return 0});ar(b,function(a){e.push(' name="',co(a),ch);return 0});e.push(">");return c.createElement(e.join(f))}var
g=aN(c,d);ar(a,function(a){return g.type=a});ar(b,function(a){return g.name=a});return g}}function
bp(a,b,c){return bo(a,b,c,cP)}var
cT=C([a,cS,0]);ab.HTMLElement===cL;var
as=[0,0];function
cV(a){if(a5(a,cW))return a;try{var
b=ba(a,as[1]);b[1]=b[1]+1|0;var
c=D(a,d(f+b[1]));return c}catch(f){f=$(f);if(f===ap){as[1]=[0,[0,a,[0,0]],as[1]];return D(a,cX)}throw f}}var
J=ab.document,q=bm(J,cU),cY=20;if(bj(q.getContext)){q.width=2e3;q.height=500;var
aO=function(a){var
b=q.width,c=q.height;return q.getContext(O).clearRect(0,0,b,c)},bq=function(a){var
b=a[2],c=a[1],d=q.getContext(O);d.strokeStyle="#FF0000";return d.strokeRect(c,b+2,a[3]-c,a[4]-b-1)},at=function(a,b){return a.style.backgroundColor=b.toString()},aQ=function(a,b){var
c=bp([0,"submit"],0,J);at(c,aP);c.value=a.toString();c.onclick=aM(b);return c},br=function(a){return bm(J,cR)},I=bo(0,0,J,cQ);I.readOnly=cM;I.value=f;I.cols=80;I.rows=10;var
aR=function(a){I.value=I.value.concat(a.toString());return I.scrollTop=I.scrollHeight},u=function(a){var
b=2===a[0]?a[3]:a[2];return b},aS=function(a,b){var
c=b[2],d=b[1];return[0,a[1]+d,a[2]+c,a[3]+d,a[4]+c]},P=function(a,b){var
c=a[2],d=a[1];switch(b[0]){case
0:var
e=aS(b[2],[0,d,c]);return[0,b[1],e];case
1:var
f=aS(b[2],[0,d,c]),g=b[1],h=[0,d,c];return[1,E(function(a){return P(h,a)},g),f];default:var
i=b[5],j=b[4],k=aS(b[3],[0,d,c]),l=P([0,d,c],b[2]);return[2,P([0,d,c],b[1]),l,k,j,i]}},ac=function(a,b){var
e=a[2],f=a[1],c=u(b),g=c[1]<=f?1:0;if(g){var
h=f<c[3]?1:0;if(h)var
i=c[2]<=e?1:0,d=i?e<c[4]?1:0:i;else
var
d=h}else
var
d=g;return d},bs=function(a,b){var
d=a,c=b;for(;;){if(c){var
e=d[2],f=d[1],g=ac([0,f,e],c[1]);if(!g){var
d=[0,f,e],c=c[2];continue}var
h=g}else
var
h=c;return h}},m=function(a){var
b=q.getContext(O);b.font=D(d(bT),c0).toString();return[0,a,[0,0,0,b.measureText(a.toString()).width,cY]]},bt=function(a,b,c,d){if(b)var
f=b[1],e=u(f),g=e[1],i=bt(a+(e[3]-g)+c,b[2],c,d),h=[0,P([0,a-g,d-e[4]],f),i];else
var
h=b;return h},r=function(a){var
d=a,c=1,j=0;for(;;){if(d){var
f=u(d[1]),i=aa(c,f[4]-f[2]),d=d[2],c=i;continue}var
g=bt(0,a,j,c),b=g;for(;;){if(b){var
e=b[2];if(e){var
b=e;continue}var
h=u(b[1])[3]}else
var
h=0;return[1,g,[0,0,0,h,c]]}}},bu=function(a,b,c){var
g=u(a),h=g[4],i=u(b),e=q.getContext(O);e.font=D(d(b$),c1).toString();var
f=e.measureText(c.toString()).width,j=h+i[4]+6,k=[0,0,0,aa(g[3],i[3])+f,j];return[2,a,P([0,0,h+6],b),k,c,f]},au=function(a){switch(a[0]){case
0:var
f=a[2],n=f[2],o=f[1],p=a[1],b=q.getContext(O);b.textBaseline="top";b.font=D(d(bT),c2).toString();return b.fillText(p.toString(),o,n);case
1:return ao(au,a[1]);default:var
g=a[2],h=a[1];au(h);au(g);var
i=u(h),j=i[3],e=u(g),k=e[3],l=e[2],m=e[1],r=aa(j-i[1],k-m);q.getContext(O).fillRect(m,l-2,r,1);var
s=aa(j,k),t=a[4],c=q.getContext(O);c.textBaseline="middle";c.font=D(d(b$),c3).toString();return c.fillText(t.toString(),s,l-2)}},K=C([a,c6,0]),Q=C([a,c7,0]),ad=function(f){var
a=[1,c8,[0,0]],b=[0,function(a){throw ap}];function
g(a){return[1,cV(a),[0,0]]}function
j(a){return[0,a]}function
k(a,b){return[2,a,b,[0,0]]}function
c(a){switch(a[0]){case
0:return a;case
1:var
f=a[2],g=f[1];if(g){var
h=c(g[1]);f[1]=[0,h];return h}return a;default:var
d=a[3],i=d[1];if(i){var
j=c(i[1]);d[1]=[0,j];return j}var
b=e(a[2],0);d[1]=[0,b];if(2===b[0])if(!b[3][1])return b;var
k=c(b);d[1]=[0,k];return k}}function
n(a){return 0}function
o(a){var
b=c(a);if(0===b[0])return b[1];throw K}function
h(d,b){var
a=c(b);switch(a[0]){case
0:var
g=a[1],j=function(a){return h(d,a)},k=i(f[1],j,g);return e(f[4],k);case
1:return a5(d,a[1]);default:return 1}}function
l(a,b){var
e=c(a),d=c(b);switch(e[0]){case
0:switch(d[0]){case
0:return fM(f[2],l,e[1],d[1]);case
1:var
j=e,m=d[2],i=d[1],g=1;break;default:var
g=0}break;case
1:var
k=e[2];switch(d[0]){case
0:var
j=d,m=k,i=e[1],g=1;break;case
1:var
n=k!==d[2]?1:0,o=n?(k[1]=[0,d],0):n;return o;default:var
g=0}break;default:var
g=0}if(g){if(h(i,j))throw[0,Q,i];m[1]=[0,j];return 0}throw[0,Q,c9]}function
d(a){var
b=c(a);switch(b[0]){case
0:var
g=i(f[1],d,b[1]);return e(f[3],g);case
1:return m(b[1]);default:return e(b[1],0)}}return[0,a,o,h,l,d,g,j,k,c,n,b]},dq=function(a,b){return[0,b[1]]},dr=function(a){return 0},ds=function(a,b,c){if(b[1]===c[1])return 0;throw[0,Q,dt]},g=ad([0,dq,ds,function(a){return m(d(f+a[1]))},dr]),bF=function(a){return e(g[7],[0,a])},du=function(a,b){var
c=0!==b?1:0,d=c?1:c;return d},dv=function(a){return 0},dw=function(a,b,c){if(0===b){var
d=0!==c?1:0;if(!d)return d}else
if(0!==c)return 0;throw[0,Q,dx]},ag=ad([0,du,dw,function(a){return 0===a?m(dy):m(dz)},dv]),av=e(ag[7],0),aw=e(ag[7],1),dA=function(a,b){return 0===b[0]?[0,b[1]]:[1,b[1]]},dB=function(a){return 0},dC=function(a,b,c){if(0===b[0]){if(0===c[0])return i(g[4],b[1],c[1])}else
if(1===c[0])return i(ag[4],b[1],c[1]);throw[0,Q,dD]},y=ad([0,dA,dC,function(a){return 0===a[0]?e(g[5],a[1]):e(ag[5],a[1])},dB]),c=function(a){return e(y[7],[0,a])},z=function(a){return e(y[7],[1,a])},dE=function(a,b){switch(b[0]){case
0:return[0,b[1]];case
1:var
c=e(a,b[2]);return[1,e(a,b[1]),c];case
2:var
d=e(a,b[2]);return[2,e(a,b[1]),d];case
3:var
f=e(a,b[2]);return[3,e(a,b[1]),f];case
4:var
g=e(a,b[2]);return[4,e(a,b[1]),g];case
5:var
h=e(a,b[2]);return[5,e(a,b[1]),h];case
8:var
j=e(a,b[3]),k=e(a,b[2]);return[8,e(a,b[1]),k,j];default:var
i=e(a,b[2]);return[6,e(a,b[1]),i]}},dF=function(a){return 0},dG=function(a,b,c){switch(b[0]){case
0:if(0===c[0])return i(y[4],b[1],c[1]);break;case
1:if(1===c[0]){i(a,b[1],c[1]);return i(a,b[2],c[2])}break;case
2:if(2===c[0]){i(a,b[1],c[1]);return i(a,b[2],c[2])}break;case
3:if(3===c[0]){i(a,b[1],c[1]);return i(a,b[2],c[2])}break;case
4:if(4===c[0]){i(a,b[1],c[1]);return i(a,b[2],c[2])}break;case
5:if(5===c[0]){i(a,b[1],c[1]);return i(a,b[2],c[2])}break;case
6:if(6===c[0]){i(a,b[1],c[1]);return i(a,b[2],c[2])}break;case
7:if(7===c[0]){i(a,b[1],c[1]);return i(a,b[2],c[2])}break;default:if(8===c[0]){i(a,b[1],c[1]);i(a,b[2],c[2]);return i(a,b[3],c[3])}}throw[0,Q,dH]},h=ad([0,dE,dG,function(a){switch(a[0]){case
0:return e(y[5],a[1]);case
1:var
b=[0,a[2],0],c=[0,m(dI),b];return r([0,a[1],c]);case
2:var
d=[0,a[2],0],f=[0,m(dJ),d];return r([0,a[1],f]);case
3:var
g=[0,a[2],0],h=[0,m(dK),g];return r([0,a[1],h]);case
4:var
i=[0,a[2],0],j=[0,m(dL),i];return r([0,a[1],j]);case
5:var
k=[0,a[2],0],l=[0,m(dM),k];return r([0,a[1],l]);case
6:var
n=[0,a[2],0],o=[0,m(dN),n];return r([0,a[1],o]);case
7:var
p=[0,a[2],0],q=[0,m(dO),p];return r([0,a[1],q]);default:var
s=[0,a[3],0],t=[0,m(dP),s],u=[0,a[2],t],v=[0,m(dQ),u],w=[0,a[1],v];return r([0,m(dR),w])}},dF]),l=function(a){return e(h[7],[0,a])},aW=function(a,b){return e(h[7],[1,a,b])},ax=function(a,b){return e(h[7],[2,a,b])},aX=function(a,b){return e(h[7],[3,a,b])},S=function(a,b){return e(h[7],[4,a,b])},dS=function(a,b){return e(h[7],[5,a,b])},ay=function(a,b){return e(h[7],[6,a,b])},dT=function(a,b){return e(h[7],[7,a,b])},aY=function(a,b,c){return e(h[7],[8,a,b,c])},dU=function(a,b){return 0===b[0]?[0,b[1],b[2],b[3]]:[1,b[1]]},dV=function(a){return 0},dW=function(a,b,c){if(0===b[0]){if(0===c[0]){i(h[4],b[1],c[1]);return i(y[4],b[2],c[2])}}else
if(1===c[0])return i(h[4],b[1],c[1]);throw[0,Q,dX]},X=ad([0,dU,dW,function(a){if(0===a[0]){try{e(a[3],0)}catch(f){}var
b=[0,e(y[5],a[2]),0],c=[0,m(dY),b];return r([0,e(h[5],a[1]),c])}return e(h[5],a[1])},dV]),k=function(a,b){var
c=[0,a,b,function(a){return 0}];return e(X[7],c)},aZ=function(a,b,c){return e(X[7],[0,a,b,c])},T=function(a){return e(X[7],[1,a])},az=function(h,b,c,d){try{var
f=e(g[2],b),k=e(g[2],c)[1],l=[0,i(h,f[1],k)],n=e(g[7],l);return n}catch(f){var
a=function(a){return az(h,b,c,d)},j=function(a){var
f=[0,e(g[5],c),0],h=[0,m(d),f];return r([0,e(g[5],b),h])};return i(g[8],j,a)}},bG=function(d,b){try{var
f=e(g[2],b),k=e(g[2],d);if(k[1]<f[1]){var
n=l(c(b)),o=ay(l(c(d)),n);return o}throw K}catch(f){f=$(f);if(f===K){var
a=function(a){return bG(d,b)},j=function(a){var
c=[0,e(g[5],b),0],f=[0,m(d2),c];return r([0,e(g[5],d),f])};return i(h[8],j,a)}throw f}},bH=function(d,b){try{var
f=e(g[2],b),k=e(g[2],d);if(f[1]<=k[1]){var
n=l(c(b)),o=dT(l(c(d)),n);return o}throw K}catch(f){f=$(f);if(f===K){var
a=function(a){return bH(d,b)},j=function(a){var
c=[0,e(g[5],b),0],f=[0,m(d3),c];return r([0,e(g[5],d),f])};return i(h[8],j,a)}throw f}},bI=function(d,b){try{var
f=e(g[2],b),k=e(g[2],d);if(k[1]===f[1]){var
n=l(c(b)),o=S(l(c(d)),n);return o}throw K}catch(f){var
a=function(a){return bI(d,b)},j=function(a){var
c=[0,e(g[5],b),0],f=[0,m(d4),c];return r([0,e(g[5],d),f])};return i(h[8],j,a)}},bJ=function(d,b){try{var
f=e(g[2],b),k=e(g[2],d);if(k[1]!==f[1]){var
n=l(c(b)),o=dS(l(c(d)),n);return o}throw K}catch(f){f=$(f);if(f===K){var
a=function(a){return bJ(d,b)},j=function(a){var
c=[0,e(g[5],b),0],f=[0,m(d5),c];return r([0,e(g[5],d),f])};return i(h[8],j,a)}throw f}},d6=function(a){var
b=e(g[6],d7),d=c(b);return[1,k(l(c(b)),d)]},d8=function(a){var
b=e(ag[6],d9),c=z(b);return[1,k(l(z(b)),c)]},d_=function(a){var
f=e(h[6],d$),j=e(h[6],ea),b=e(g[6],eb),d=e(g[6],ec),m=e(g[6],ed),o=l(c(d)),p=aW(l(c(b)),o),n=c(az(function(a,b){return a+b|0},b,d,dZ)),q=[0,[0,T(S(p,l(n))),0],0],r=[0,[0,k(j,c(d)),0],q],s=[0,[0,k(f,c(b)),0],r];function
t(a){var
b=c(m);return i(y[4],n,b)}var
u=c(m);return[0,aZ(aW(f,j),u,t),s]},ee=function(a){var
f=e(h[6],ef),j=e(h[6],eg),b=e(g[6],eh),d=e(g[6],ei),m=e(g[6],ej),o=l(c(d)),p=ax(l(c(b)),o),n=c(az(function(a,b){return a-b|0},b,d,d0)),q=[0,[0,T(S(p,l(n))),0],0],r=[0,[0,k(j,c(d)),0],q],s=[0,[0,k(f,c(b)),0],r];function
t(a){var
b=c(m);return i(y[4],n,b)}var
u=c(m);return[0,aZ(ax(f,j),u,t),s]},ek=function(a){var
f=e(h[6],el),j=e(h[6],em),b=e(g[6],en),d=e(g[6],eo),m=e(g[6],ep),o=l(c(d)),p=aX(l(c(b)),o),n=c(az(function(a,b){return f1(a,b)},b,d,d1)),q=[0,[0,T(S(p,l(n))),0],0],r=[0,[0,k(j,c(d)),0],q],s=[0,[0,k(f,c(b)),0],r];function
t(a){var
b=c(m);return i(y[4],n,b)}var
u=c(m);return[0,aZ(aX(f,j),u,t),s]},eq=function(a){var
j=z(av),b=e(h[6],er),d=e(h[6],es),f=e(g[6],et),i=e(g[6],eu),l=[0,[0,T(bI(f,i)),0],0],m=[0,[0,k(d,c(i)),0],l],n=[0,[0,k(b,c(f)),0],m];return[0,k(S(b,d),j),n]},ev=function(a){var
j=z(aw),b=e(h[6],ew),d=e(h[6],ex),f=e(g[6],ey),i=e(g[6],ez),l=[0,[0,T(bJ(f,i)),0],0],m=[0,[0,k(d,c(i)),0],l],n=[0,[0,k(b,c(f)),0],m];return[0,k(S(b,d),j),n]},eA=function(a){var
j=z(av),b=e(h[6],eB),d=e(h[6],eC),f=e(g[6],eD),i=e(g[6],eE),l=[0,[0,T(bG(f,i)),0],0],m=[0,[0,k(d,c(i)),0],l],n=[0,[0,k(b,c(f)),0],m];return[0,k(ay(b,d),j),n]},eF=function(a){var
j=z(aw),b=e(h[6],eG),d=e(h[6],eH),f=e(g[6],eI),i=e(g[6],eJ),l=[0,[0,T(bH(f,i)),0],0],m=[0,[0,k(d,c(i)),0],l],n=[0,[0,k(b,c(f)),0],m];return[0,k(ay(b,d),j),n]},eK=function(a){var
f=z(av),b=e(h[6],eL),c=e(h[6],eM),g=e(h[6],eN),d=e(y[6],eO),i=[0,[0,k(c,d),0],0],j=[0,[0,k(b,f),0],i];return[0,k(aY(b,c,g),d),j]},eT=0,bK=[0,[0,e4,d6],[0,[0,e3,d8],[0,[0,e2,d_],[0,[0,e1,ee],[0,[0,e0,ek],[0,[0,eZ,eq],[0,[0,eY,ev],[0,[0,eX,eA],[0,[0,eW,eF],[0,[0,eV,eK],[0,[0,eU,function(a){var
f=z(aw),b=e(h[6],eP),g=e(h[6],eQ),c=e(h[6],eR),d=e(y[6],eS),i=[0,[0,k(c,d),0],0],j=[0,[0,k(b,f),0],i];return[0,k(aY(b,g,c),d),j]}],eT]]]]]]]]]]],e6=e5.slice(),e7=[0,264,0],fd=bY,fi=function(a){throw[0,bd,b(a,0)]},fj=function(a){var
c=b(a,2);return k(c,b(a,0))},fk=function(a){return b(a,1)},fl=function(a){var
d=b(a,0);return ax(l(c(bF(0))),d)},fm=function(a){var
c=b(a,4),d=b(a,2);return aY(c,d,b(a,0))},fn=function(a){var
c=b(a,2);return ay(c,b(a,0))},fo=function(a){var
c=b(a,2);return S(c,b(a,0))},fp=function(a){var
c=b(a,2);return aX(c,b(a,0))},fq=function(a){var
c=b(a,2);return ax(c,b(a,0))},fr=function(a){var
c=b(a,2);return aW(c,b(a,0))},fs=function(a){return l(z(b(a,0)))},ft=function(a){return l(c(b(a,0)))},fu=function(a){return b(a,1)},fv=function(a){return z(b(a,0))},fw=function(a){return c(b(a,0))},fx=function(a){return b(a,1)},fy=function(a){return aw},fz=function(a){return av},fA=function(a){return b(a,1)},fB=function(a){return bF(b(a,0))},fC=function(a){var
c=[0,-b(a,0)|0];return e(g[7],c)},fD=function(a){return b(a,1)},fF=[0,[0,function(a){return am(fE)},fD,fC,fB,fA,fz,fy,fx,fw,fv,fu,ft,fs,fr,fq,fp,fo,fn,fm,fl,fk,fj,fi],e6,e7,e8,e9,e_,e$,fa,fb,fc,fd,fe,ff,cI,fg,fh],fH=function(a){a:for(;;){var
d=0;for(;;){var
b=fX(fG,d,a);if(0<=b){a[11]=a[12];var
c=a[12];a[12]=[0,c[1],c[2],c[3],a[4]+a[6]|0]}if(17<b>>>0){e(a[1],a);var
d=b;continue}switch(b){case
2:return 0;case
3:return 1;case
4:return 2;case
5:return 3;case
6:return 4;case
7:return 5;case
8:return 6;case
9:return 7;case
10:return 8;case
11:return[0,fW(bc(a))];case
12:return 9;case
13:return 10;case
14:return 11;case
15:return 12;case
16:return 13;case
17:return am(D(fI,bc(a)));default:continue a}}}},a0=X[5],fJ=X[4],fK=X[1],v=function(a){var
b=0===a[0]?a[3]:a[4];return b},aT=function(a){return au(v(a))},bv=function(a,b){var
c=a[2],d=a[1];if(0===b[0]){var
e=P([0,d,c],b[3]);return[0,b[1],b[2],e]}var
f=P([0,d,c],b[4]),g=b[3],h=b[2],i=[0,d,c],j=E(function(a){return bv(i,a)},h);return[1,b[1],j,g,f]},bw=function(a,b){return[0,a,b,bu(c_,e(a0,a),b)]},bx=function(a,b,c,d){if(b)var
f=b[1],e=u(v(f)),g=e[1],i=bx(a+(e[3]-g)+c,b[2],c,d),h=[0,bv([0,a-g,d-(e[4]-e[2])],f),i];else
var
h=b;return h},R=function(a,b,c){if(0===b)return[1,a,0,c,e(a0,a)];var
g=b,f=1;for(;;){if(g){var
j=u(v(g[1])),l=aa(f,j[4]-j[2]),g=g[2],f=l;continue}var
h=bx(0,b,5,f),d=h;for(;;){if(d){var
i=d[2];if(i){var
d=i;continue}var
k=u(v(d[1]))[3]}else
var
k=0;var
m=[1,E(v,h),[0,0,0,k,f]];return[1,a,h,c,bu(m,e(a0,a),c)]}}},by=function(a,b){if(0===b[0]){var
c=b[2],d=E(function(a){return by(c$,a)},c);return R(b[1],d,a)}return bw(b[1],a)},bz=function(a,b){var
c=a[2],d=a[1],e=ac([0,d,c],v(b));if(e){if(0===b[0])return bq(u(v(b)));var
f=b[2];if(bs([0,d,c],E(v,f))){var
g=[0,d,c];return ao(function(a){return bz(g,a)},f)}return bq(u(v(b)))}return e},ae=function(a,b,c){if(a5(b,da))return R(a,0,db);var
d=e(ba(b,c),0);i(fJ,a,d[1]);return by(b,d)},aU=function(a,b,c,d,e){var
f=c[2],g=c[1];if(ac([0,g,f],v(b))){if(0===b[0])return ae(a,d,e);var
j=b[2];if(bs([0,g,f],E(v,j))){var
h=ae(a,b[3],e);if(0===h[0])return am(dc);var
k=h[2],l=aK(function(a,b){return aU(a[1],b,[0,g,f],d,e)},k,j);return R(h[1],l,h[3])}return ae(a,d,e)}if(0===b[0])return ae(a,b[2],e);var
i=ae(a,b[3],e);if(0===i[0])return am(dd);var
m=b[2],n=i[2],o=aK(function(a,b){return aU(a[1],b,[0,g,f],d,e)},n,m);return R(i[1],o,i[3])},bA=function(a){if(0===a[0])return bw(a[1],a[2]);var
b=a[3],c=E(bA,a[2]);return R(a[1],c,b)},bL=function(a){var
b=D(a,fL),c=A(b),d=H(c);Y(b,0,d,0,c);var
e=[0],f=1,g=0,h=0,i=0,j=0,k=0,l=A(b);return cG(fF,1,fH,[0,function(a){a[9]=1;return 0},d,l,k,j,i,h,g,f,e,bb,bb])},aV=[0,de],G=[0,R(fK,0,df)],W=[0,bB],af=[0,0],bC=function(a){var
b=af[1];return ao(function(a){return at(a[2],aP)},b)},bD=function(a){as[1]=0;var
b=bL(aV[1]);return bA(aU(b,G[1],W[1],a,bK))},bE=function(a,b){bC(0);var
c=v(G[1]);if(ac(W[1],c)){G[1]=bD(a);aO(0);aT(G[1])}W[1]=bB;return aq},dh=function(a){return bE(di,a)},dl=function(a){aO(0);aT(G[1]);var
b=q.getBoundingClientRect();W[1]=[0,a.clientX-b.left,a.clientY-b.top];bz(W[1],G[1]);var
d=v(G[1]);if(ac(W[1],d)){aR(dj);var
c=af[1];ao(function(a){var
b=a[2],c=a[1];try{bD(c);aR(D(c,dk));var
d=at(b,cZ);return d}catch(f){return at(b,aP)}},c);aR(c5)}else
bC(0);return aq};ab.onload=aM(function(a){var
b=J.getElementById("main");if(b==bi)throw[0,a$,c4];q.onmousedown=aM(dl);var
d=J.createDocumentFragment();F(d,J.createTextNode("Input Term: "));F(b,d);var
c=bp([0,"text"],0,J);c.value="5 + 1 to 6";F(b,c);F(b,aQ(dm,function(a){aV[1]=aF(c.value);G[1]=R(bL(aV[1]),0,dg);aO(0);aT(G[1]);return aq}));F(b,br(0));af[1]=E(function(a){var
c=a[1],d=aQ(c,function(a){return bE(c,a)});F(b,d);return[0,c,d]},bK);var
e=aQ(dn,dh);af[1]=[0,[0,dp,e],af[1]];F(b,e);F(b,br(0));F(b,q);return aq});var
cx=function(a){var
b=a;for(;;){if(b){var
c=b[2],d=b[1];try{fY(d)}catch(f){}var
b=c;continue}return 0}};cx(f0(0));return}throw cT}(function(){return this}()));
