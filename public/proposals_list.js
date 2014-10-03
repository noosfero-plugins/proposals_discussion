jQuery(document).ready(function($) {
  initTwitterButton();
  initFacebookButton();
  $('#content').on('mouseenter', '.proposal', function() {
      loadSocialButtons();
      $('.proposal .actions').hide();
      $(this).find('.actions').show("fast");
    }).on('mouseleave', '.proposal', function() {
      $(this).find('.actions').hide("fast");
  });

  function proposalsScroll() {
    var scroll = $('.article-body-proposals-discussion-plugin_topic .topic-content .proposals_list .proposals');
    var nextSelector = 'div.more a';
    if(scroll.data('jscroll')) scroll.data('jscroll', null);

    if(scroll.find(nextSelector).length > 0) {
      scroll.jscroll({
        loadingHtml: '<img src="/images/loading.gif" alt="Loading" />Loading...',
        nextSelector: nextSelector
      });
    }
  }
  $('.filters .random').click();

  $('.proposals_list .filters a.order').on('ajax:success', function(event, data, status, xhr) {
    $(this).parents('div.proposals_list').find('.filters a.order').removeClass('selected');
    $(this).addClass('selected');
    $(this).parents('div.proposals_list').find('.proposals').html(data);
    proposalsScroll();
    $('.topics').masonry();
  });
  $('.topics').masonry();
});

function loadSocialButtons() {
  twttr.widgets.load();
  try{FB.XFBML.parse();}catch(ex){}
}
function initFacebookButton() {
  (function(d, s, id) {
    var js, fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) return;
    js = d.createElement(s); js.id = id;
    js.src = "//connect.facebook.net/pt_BR/sdk.js#xfbml=1&version=v2.0";
    fjs.parentNode.insertBefore(js, fjs);
  }(document, 'script', 'facebook-jssdk'));
}
function initTwitterButton() {
  !function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');
}
