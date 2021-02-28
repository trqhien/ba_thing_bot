import App
import Vapor
import TelegramBotSDK

typealias Router = TelegramBotSDK.Router

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
//try configure(app)
//try app.run()

let token = "1548913077:AAFbJMlNGApA2SpEGoZrSn8lF7tEmx9--C4"
let bot = TelegramBot(token: token)
//var routers = [String: Router]()
var router = Router(bot: bot)

let controller = QuotesController(bot: bot, app: app, router: &router)
let testController = TestController(bot: bot, router: &router)


print("🌮Ready to accept commands")
while let update = bot.nextUpdateSync() {
    print("--- update: \(update.message?.text)")

    try router.process(update: update)
}
print("🌮Server stopped due to error: \(bot.lastError.unwrapOptional)")
