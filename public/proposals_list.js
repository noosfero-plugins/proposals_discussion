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
    $('.proposals').data('jscroll', null);
    $('.proposals').jscroll({
      loadingHtml: '<img src="/images/loading.gif" alt="Loading" />Loading...',
      nextSelector: 'div.more a'
    });
    $('.proposals').trigger('scroll.jscroll');
  }
  proposalsScroll();

  $('.proposals_list .filters a.order').on('ajax:success', function(event, data, status, xhr) {
    $('.proposals_list .filters a.order').removeClass('selected');
    $(this).addClass('selected');
    $(this).parents('div.proposals_list').find('.proposals').html(data);
    proposalsScroll();
  });
});
