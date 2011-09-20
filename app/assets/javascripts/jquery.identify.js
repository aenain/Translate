jQuery.fn.identify = function(prefix) {
    var i = 0;
    return this.each(function() {
        if($(this).attr('id')) return;
        do { 
            i++;
            var id = prefix + '_' + i;
        } while(document.getElementById(id) != null);            
        $(this).attr('id', id);            
    });
};