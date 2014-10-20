require.config( {
	paths: {
		'req-ext': '/bower_components/js/req-ext'
	}
} );

require( [
	'req-ext',
	'javascript/req-sub'
], function ( ext, sub ) {
	'use strict';

	document.getElementById( 'req-main' ).style.color = 'green';

	return console.log( ['LOADED: MAIN', sub, ext].join( ', ' ) );
} );
