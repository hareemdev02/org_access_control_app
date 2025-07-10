//= require rails-ujs
//= require turbolinks
//= require_tree .

// Handle DELETE method for sign out links
document.addEventListener('DOMContentLoaded', function() {
  document.addEventListener('click', function(e) {
    if (e.target.matches('a[data-method="delete"]')) {
      e.preventDefault();
      
      var link = e.target;
      var url = link.getAttribute('href');
      var csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
      
      var form = document.createElement('form');
      form.method = 'POST';
      form.action = url;
      
      var methodInput = document.createElement('input');
      methodInput.type = 'hidden';
      methodInput.name = '_method';
      methodInput.value = 'DELETE';
      
      var csrfInput = document.createElement('input');
      csrfInput.type = 'hidden';
      csrfInput.name = 'authenticity_token';
      csrfInput.value = csrfToken;
      
      form.appendChild(methodInput);
      form.appendChild(csrfInput);
      document.body.appendChild(form);
      form.submit();
    }
  });
}); 