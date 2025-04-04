function escapeHtml(s) {
    var amp = /&/g, lt = /</g, gt = />/g;
    return s.toString()
        .replace(amp, '&amp;')
        .replace(lt, '&lt;')
        .replace(gt, '&gt;');
}

function escapeAttr(s) {
    return s.toString()
         .replace(/'/g, '%22')
         .replace(/"/g, '%27');
}

function test() {
  var tainted = window.name; // $ Source
  var elt = document.createElement();
  elt.innerHTML = "<a href=\"" + escapeAttr(tainted) + "\">" + escapeHtml(tainted) + "</a>";
  elt.innerHTML = "<div>" + escapeAttr(tainted) + "</div>"; // $ MISSING: Alert - not flagged -

  const regex = /[<>'"&]/;
  if (regex.test(tainted)) {
    elt.innerHTML = '<b>' + tainted + '</b>'; // $ Alert
  } else {
    elt.innerHTML = '<b>' + tainted + '</b>';
  }
  if (!regex.test(tainted)) {
    elt.innerHTML = '<b>' + tainted + '</b>';
  } else {
    elt.innerHTML = '<b>' + tainted + '</b>'; // $ Alert
  }
  if (regex.exec(tainted)) {
    elt.innerHTML = '<b>' + tainted + '</b>'; // $ Alert
  } else {
    elt.innerHTML = '<b>' + tainted + '</b>';
  }
  if (regex.exec(tainted) != null) {
    elt.innerHTML = '<b>' + tainted + '</b>'; // $ Alert
  } else {
    elt.innerHTML = '<b>' + tainted + '</b>';
  }
  if (regex.exec(tainted) == null) {
    elt.innerHTML = '<b>' + tainted + '</b>';
  } else {
    elt.innerHTML = '<b>' + tainted + '</b>'; // $ Alert
  }

  elt.innerHTML = tainted.replace(/<\w+/g, ''); // $ Alert
}
