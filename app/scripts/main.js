if ( typeof DEBUG === 'undefined' ) DEBUG = true;

// TEST: is debug mode on or off?
if ( DEBUG ) document.getElementById('debug-mode').textContent = 'ON';

// TEST: testing if the comment was left.

// TEST: main file inclusion.
document.getElementById('js-main').style.color = 'green';

// TEST: Was console object left?
console.log('Console object was left.');

// TEST: image name rewite in the JS file by the rev task.
document.getElementById('js-img').src = 'images/js-img.png';
