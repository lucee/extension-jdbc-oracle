component extends="org.lucee.cfml.test.LuceeTestCase" labels="oracle" {

	// keep in sync with pom.xml mvnVersion (major.minor.patch prefix)
	variables.mavenDriverVersionPrefix = "23.8.0.25.04";

	function isNotSupported() {
		return isEmpty( server.getDatasource( "oracle" ) );
	}

	private boolean function luceeSupportsMavenJdbc() {
		try {
			return server.doesJDBCSupportMaven();
		} catch ( any e ) {
			return false;
		}
	}

	private struct function getRegisteredJdbcDriver() {
		var driver = {
			available: false,
			class: "",
			maven: "",
			bundleName: "",
			bundleVersion: "",
			error: "",
			mode: "bundle"
		};

		try {
			if ( structKeyExists( server, "getOracleJdbcDriverDefinition" ) ) {
				var jdbc = server.getOracleJdbcDriverDefinition();
				driver.available = true;
				driver.class = jdbc.class;
				driver.maven = jdbc.maven ?: "";
				driver.bundleName = jdbc.bundleName ?: "";
				driver.bundleVersion = jdbc.bundleVersion ?: "";
			} else {
				var ds = server.getDatasource( "oracle" );
				driver.available = !isEmpty( ds );
				driver.class = ds.class ?: "";
				driver.maven = ds.maven ?: "";
				driver.bundleName = ds.bundleName ?: "";
				driver.bundleVersion = ds.bundleVersion ?: "";
			}

			driver.mode = ( len( driver.maven ) && luceeSupportsMavenJdbc() ) ? "maven" : "bundle";
		} catch ( any e ) {
			driver.error = e.message;
		}

		return driver;
	}

	private struct function getDatasourceResolution( required struct ds ) {
		var usesMaven = structKeyExists( arguments.ds, "maven" ) && len( arguments.ds.maven );

		return {
			mode: usesMaven ? "maven" : "bundle",
			maven: usesMaven ? arguments.ds.maven : "",
			bundleName: structKeyExists( arguments.ds, "bundleName" ) ? arguments.ds.bundleName : "",
			bundleVersion: structKeyExists( arguments.ds, "bundleVersion" ) ? arguments.ds.bundleVersion : "",
			luceeSupportsMavenJdbc: luceeSupportsMavenJdbc()
		};
	}

	private any function createJavaClass( required struct ds, required struct resolution ) {
		if ( arguments.resolution.mode eq "maven" ) {
			return createObject(
				"java",
				arguments.ds.class,
				{ maven: [ arguments.resolution.maven ] }
			);
		}

		if ( structKeyExists( arguments.ds, "bundleName" ) && len( arguments.ds.bundleName ) ) {
			return createObject(
				"java",
				arguments.ds.class,
				arguments.ds.bundleName,
				arguments.ds.bundleVersion
			);
		}

		return createObject( "java", arguments.ds.class );
	}

	private struct function getDriverBundleInfo( required struct ds, required struct resolution ) {
		var javaClass = createJavaClass( arguments.ds, arguments.resolution );

		if ( arguments.resolution.mode eq "maven" ) {
			var gav = arguments.resolution.maven;
			return {
				name: listGetAt( gav, 1, ":" ) & ":" & listGetAt( gav, 2, ":" ),
				version: listGetAt( gav, 3, ":" )
			};
		}

		return bundleInfo( javaClass );
	}

	function run( testResults, testBox ) {
		describe( title="Oracle JDBC extension driver version", body=function() {
			it(
				title="reports the Oracle JDBC driver version in use",
				skip=isNotSupported(),
				body=function( currentSpec ) {
					var ds = server.getDatasource( "oracle" );
					var resolution = getDatasourceResolution( ds );
					var registeredDriver = getRegisteredJdbcDriver();
					var bundle = getDriverBundleInfo( ds, resolution );

					dbinfo datasource=ds name="local.dbVersion" type="version";

					var info = {
						luceeVersion: server.lucee.version,
						datasourceClass: ds.class,
						datasourceResolution: resolution,
						registeredJdbcDriver: registeredDriver,
						bundleInfoName: bundle.name,
						bundleInfoVersion: bundle.version,
						driverName: dbVersion.driver_name,
						driverVersion: dbVersion.driver_version,
						databaseProduct: dbVersion.database_productname,
						databaseVersion: dbVersion.database_version,
						jdbcVersion: dbVersion.jdbc_major_version & "." & dbVersion.jdbc_minor_version
					};

					systemOutput( "Oracle JDBC driver info: " & serializeJSON( info ), true );

					expect( dbVersion.recordCount ).toBe( 1 );
					expect( dbVersion.driver_name ).toInclude( "Oracle" );

					if ( resolution.mode eq "maven" ) {
						expect( dbVersion.driver_version ).toInclude( variables.mavenDriverVersionPrefix );
					} else {
						systemOutput( "Oracle JDBC driver loaded via OSGi bundle (#resolution.bundleName# #resolution.bundleVersion#); Maven version assertion skipped", true );
					}
				}
			);
		} );
	}

}
