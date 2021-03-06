
import Foundation
import Dynamo

#if os(Linux)
import Glibc
#endif

system( "tar xfz site.tgz -C ~" )

// create non-SSL server/proxy on 8080
_ = DynamoWebServer( portNumber: 8080, swiftlets: [
    LoggingSwiftlet( logger: dynamoTrace ),
    ExampleAppSwiftlet( pathPrefix: "/example" ),
    SessionSwiftlet( pathPrefix: "/ticktacktoe",  appClass: TickTackToeSwiftlet.self, cookieName: "TTT" ),
    SessionSwiftlet( pathPrefix: "/guesser",  appClass: NumberGuesserSwiftlet.self, cookieName: "NBR" ),
    SSLProxySwiftlet( logger: { (msg) in print( msg ) } ),
    ProxySwiftlet( logger: { (msg) in print( msg ) } ),
    DocumentSwiftlet( documentRoot: String(cString: getenv( "HOME" ))+"/Sites" )
] )

func pidLogger( msg: String ) {
    print( "\(getpid()): \(msg)" )
}

#if os(Linux)
// create worker process based server on 8081
_ = DynamoWorkerServer( portNumber: 8081, swiftlets: [
    LoggingSwiftlet( logger: pidLogger ),
    ExampleAppSwiftlet( pathPrefix: "/example"),
    SSLProxySwiftlet( logger: pidLogger ),
    ProxySwiftlet( logger: pidLogger ),
    DocumentSwiftlet( documentRoot: String(cString: getenv( "HOME" ) )+"/Sites" )
], workers: 4 )
#endif

// let pthreads do their work
RunLoop.current.run()
