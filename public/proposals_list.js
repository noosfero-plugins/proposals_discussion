function initTwitterButton() {
  !function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');
}

jQuery(document).ready(function($) {
  initTwitterButton();
  $('.proposals').on('mouseenter', '.proposal', function() {
      twttr.widgets.load();
      $('.proposal .social').hide();
      $(this).find('.social').show("fast");
    }).on('mouseleave', '.proposal', function() {
      $(this).find('.social').hide("fast");
  });

  function proposalsScroll() {
    $('.article-body-proposals-discussion-plugin_topic .topic-content').data('jscroll', null);
    $('.article-body-proposals-discussion-plugin_topic .topic-content').jscroll({
      loadingHtml: '<img src="/images/loading.gif" alt="Loading" />Loading...',
      nextSelector: 'div.more a'
    });
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


(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/pt_BR/sdk.js#xfbml=1&version=v2.0";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));
