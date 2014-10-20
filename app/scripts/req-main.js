require.config( {
	paths: {
		// Defining the path to bower_components using ../../ makes the build possible, since it
		// will look for the folder two paths below, where it really is. It doesn't affect the development
		// server since browser will not look for files further below the root (that's where the bower_components
		// catalogue is placed).
		'lib': '../../bower_components/js'
	}
} );

require( [
	'lib/req-ext',
	'javascript/req-sub'
], function ( ext, sub ) {
	'use strict';

	document.getElementById( 'req-main' ).style.color = 'green';

	return console.log( ['LOADED: MAIN', sub, ext].join( ', ' ) );
} );
