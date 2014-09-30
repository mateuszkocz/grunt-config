if ( typeof DEBUG === 'undefined' ) DEBUG = true;

document.querySelector( 'body' ).appendChild(
	document.createTextNode( 'JS included' )
);
console.log('YOLO');
if ( DEBUG ) {
	alert('DEBUG EXISTS')
}
