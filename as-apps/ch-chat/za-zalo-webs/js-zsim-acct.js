// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Zalo-like simulator account pages: logout, devices, settings, storage, help, feedback, password, unfriend
// Flo: label table additions > state additions > Z.xtra builds the buttons and panels on every page rebuild
// I/O: none > Z.st.out devout sets fb unfr; Z.devs; Z.xtra(S) called by buildUI
// ===================================================================
T.logout=['Đăng xuất','Log out',0,0];T.confirm=['Xác nhận','Confirm',0,0];T.devices=['Thiết bị đăng nhập','Logged-in devices',0,0];T.devout=['Đăng xuất thiết bị','Log out device',0,0];T.devpref=['Thiết bị: ','Device: ',0,0];T.sett=['Cài đặt','Settings',0,0];T.notn=['Bật thông báo máy tính','Turn on desktop notifications',0,0];T.notf=['Tắt thông báo máy tính','Turn off desktop notifications',0,0];T.lanv=['Tiếng Việt','Vietnamese',0,0];T.lane=['English','English',0,0];T.setpref=['Trạng thái: ','Status: ',0,0];T.storage=['Dung lượng lưu trữ','Storage',0,0];T.stpref=['Đã dùng: ','Used: ',0,0];T.help=['Trợ giúp','Help',0,0];T.hlpref=['Trợ giúp: ','Help: ',0,0];T.feedback=['Góp ý','Feedback',0,0];T.fbox=['Nội dung góp ý','Feedback text',0,0];T.fsend=['Gửi góp ý','Submit feedback',0,0];T.pwd=['Đổi mật khẩu','Change password',0,0];T.pwnote=['Nhập mật khẩu mới trên trang này','Type the new password on this page',0,0];T.unfr=['Hủy kết bạn','Unfriend',0,0];
Z.st.out=[];Z.st.devout=[];Z.st.sets={notify:'off',lang:'vi'};Z.st.fb=[];Z.st.unfr=[];Z.devs=['Chrome Windows','iPhone'];
Z.xtra=function(S){
panel('lo','logout',function(d){var b=el('button',{'aria-label':t('confirm')},'ok');b.onclick=function(){S.out.push('1');Z.overlay('login')};d.appendChild(b)});
panel('uf','unfr',function(d){var b=el('button',{'aria-label':t('confirm')},'ok');b.onclick=function(){S.unfr.push(Z.cur)};d.appendChild(b)});
panel('dv','devices',function(d){Z.devs.forEach(function(n){d.appendChild(el('div',{role:'note','aria-label':t('devpref')+n},n));var b=el('button',{'aria-label':t('devout')+' '+n},'x');b.onclick=function(){S.devout.push(n);Z.devs=Z.devs.filter(function(x){return x!=n});d.innerHTML='';d.appendChild(el('div',{role:'note','aria-label':'ok'},'ok'))};d.appendChild(b)})});
panel('se','sett',function(d){[['notn','notify','on'],['notf','notify','off'],['lanv','lang','vi'],['lane','lang','en']].forEach(function(p){var b=el('button',{'aria-label':t(p[0])},p[0]);b.onclick=function(){S.sets[p[1]]=p[2];if(p[1]=='lang'){Z.lang=p[2];buildUI();renderList()}else{d.innerHTML='';build2(d)}};d.appendChild(b)});build2(d);function build2(x){x.appendChild(el('div',{role:'status','aria-label':t('setpref')+'notify='+S.sets.notify},'n'));x.appendChild(el('div',{role:'status','aria-label':t('setpref')+'lang='+S.sets.lang},'l'))}});
panel('sg','storage',function(d){d.appendChild(el('div',{role:'note','aria-label':t('stpref')+'12 MB'},'12 MB'))});
panel('hp','help',function(d){d.appendChild(el('div',{role:'note','aria-label':t('hlpref')+'help.zalo.me'},'help'))});
dlg('fb','feedback',['fbox'],'fsend',function(v){S.fb.push(v[0])});
panel('pw','pwd',function(d){d.appendChild(el('div',{role:'note','aria-label':t('pwnote')},'pw'))})};
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
