var myRegexp = /SNR=(\d{6})/ig;
var array = [];

$("fieldset table tbody tr td a").each(function(i, tr) {
    var string = myRegexp.exec(tr.toString());
    if(string) {
        array.push(string[1])
    }
});

console.clear();

array.join(',');
