//main entry point of app

// way it works is that we have our MusicBridge Protocol with some functions
// This protocol is implemented by the objC MusicBridgeClass. This class is created
// by ApplescripttoObjC and automatically converts the applescript functions to a
// class. The functions in the applescript are converted to functions with the same name
// in ObjC. We the cast this to our MusicBridge protocol, ensuring that at least all of
// the functions in the MusicBridge protocol are implemented by functions in the ObjC
// class, i.e all of the methods in the protocol are implemented by the applescript.
// However, the underlying object is still the same objC class. So when we call the MusicBridge functions, we are calling the underlying objC implementations and thus the
// applescript functions.

// quick note about UI. UI is defined in the MainMenu.xib file. Click on a UI element. Then the second last element on the sidebar should dispaly a bunch of drop down menus such as value, availability etc. This is where you set the variable bindings and model etc. So we can bind a text field to the trackAlbum variable for example.
import Cocoa
import Accelerate
import AppleScriptObjC // ASOC adds its own 'load scripts' method to NSBundle

@available(macOS 10.15, *)

// Implements NSApplicationDelegate Protocol

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem!
    let mainBundle = Bundle.main
    // Cocoa Bindings
    // neccessary to put the obj dynamic decorator to make it work with the xib bindings
    // basically tells swift to use the objC versions of these functions. Without this
    // the key value pairs in the xib dont work
    @objc dynamic var trackAlbum: NSString!
    
    //path relative to .app file not swift directory.
    @objc dynamic var defaultpath: NSString?
    
    var img_path1: NSString = ""
    var img_path2: NSString = ""
    var path_switch = false
    //fixes setting desktop image. Only works if you switch between two seperate files each time
    
    var screen_dimension = (1440, 900)
    @objc dynamic var image_scale_in_bg = 2.0

        
    
    // AppleScriptObjC object for communicating with iTunes. The type is MusicBridge, which means that the underlying object represented by the variable must implement at least all of the functions defined in the MusicBridge protocol.
    var MusicBridge: MusicBridge
    
    override init() {
        // AppleScriptObjC setup
        Bundle.main.loadAppleScriptObjectiveCScripts()
        
        img_path1 = Bundle.main.path(forResource: "test.png", ofType:nil)! as NSString
        img_path2 = Bundle.main.path(forResource: "test2.png", ofType:nil)! as NSString
        defaultpath = (Bundle.main.path(forResource: "defaultWallpaper.jpg", ofType:nil)) as NSString?
        
        
        // converts Applescripts implicitly to a objC class. The class functions have the same names as the applescript ones
        let MusicBridgeClass: AnyClass = NSClassFromString("AppleScripts")!
        
        // typecasts the converted applescript class to our MusicBridge Swift protocol to ensure that all of the functions are implemented. We could just use the MusicBridgeClass objC directly, but this is a good way to check conformity.
        // Also our MusicBridge protocol has extensions that convert NSdata to swift primitives. These extensions mean that the applescript doesn't need to contain functions with those names, but we can easily call those extension functions to get swift data types back instead of nsdata. For example, the isrunning sends back a number, not a bool, but we can use the extension to access it, implicitly converting it.
        self.MusicBridge = MusicBridgeClass.alloc() as! MusicBridge

        // general application setup
        super.init()
    }

    //

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupMenus()
        // iTunes emits track change notifications; very handy for UI refreshes
        let dnc = DistributedNotificationCenter.default()
        dnc.addObserver(self, selector:#selector(AppDelegate.updateTrackInfo),
                         name:NSNotification.Name(rawValue:"com.apple.iTunes.playerInfo"), object:nil)
       
        if let screen = NSScreen.main {
            let rect = screen.frame
            screen_dimension.0 = Int(rect.size.width)
            screen_dimension.1 = Int(rect.size.height)
        }
        
        if self.MusicBridge.isRunning() {
            self.updateTrackInfo()
        }
        else{
            statusItem.menu?.item(withTag: 0)?.title = "Not Playing"
        }
    }
    
    func setupMenus() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button!.title = "🎷"
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Not playing", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Relative Artwork Size:", action: nil, keyEquivalent: ""))
        
        let menuSliderItem = NSMenuItem()
        let menuSlider = NSSlider()

        menuSlider.sliderType = NSSlider.SliderType.linear
        menuSlider.isEnabled = true
        menuSlider.isContinuous = true
        menuSlider.action = #selector(delegate.updateImageRatio)
        menuSlider.minValue = 0.1
        menuSlider.maxValue = 1
        menuSlider.floatValue = 0.5
        menuSlider.frame.size.width = menu.size.width-20
        menuSlider.frame.size.height = 30
        menuSlider.frame.origin = CGPoint(x: 20, y: 0)
        
        let view = NSView()
        view.frame.size.width = menu.size.width
        view.frame.size.height = 40
        
        view.addSubview(menuSlider)
        menuSliderItem.view = view
        menuSliderItem.tag = 10

        menu.addItem(menuSliderItem)
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Refresh Wallpaper", action: #selector(delegate.updateTrackInfo), keyEquivalent: ""))
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        }
    
    @objc func updateImageRatio() {
        let slider:NSSlider = (statusItem.menu?.item(withTag: 10)?.view?.subviews[0])! as! NSSlider
        image_scale_in_bg = Double(1/slider.floatValue)
    }
    
    @objc func updateTrackInfo(){
        
        // trackInfo returns either NSstring or nil. So this if let is a good way of checking if there is a track playing or not. This also means, we dont have to check if track is playing in the trackArtwork applescript, since we can just call the trackartwork function when we are sure there is a track playing
        if let trackInfo = self.MusicBridge._trackInfo(), let artwork = self.MusicBridge._trackArtwork(){
            self.trackAlbum = trackInfo
            statusItem.menu?.item(withTag: 0)?.title = "Album: " + (trackInfo as String)
            let ns_artwork = NSImage(data: artwork as Data)!
            let ns_small_artwork = resize(image: ns_artwork, w: 40, h: 40)
            
            let pixelArray = imageToPixel(image: ns_small_artwork)
            let dominantColor = DominantColorKMeans(pixelArray: pixelArray)

            let backgroundColorImage = generateBackgroundColorImage(size: self.screen_dimension, color: dominantColor)
            
            let ns_result = overlayImages(source: ns_artwork, destination: backgroundColorImage)
            
            setDesktop(dataToFile(bitmapToPngData(nsImageToBitmap(ns_result))))
        }
        
        else{
            statusItem.menu?.item(withTag: 0)?.title = "Not Playing"
            self.trackAlbum = ("Not Playing" as NSString)
            if let default_path = self.defaultpath{
                self.setDesktop(default_path)
            }
        }
    }
    
    func resize(image: NSImage, w: Int, h: Int) -> NSImage {
        let destSize = NSSize(width: w, height: h)
        let newImage = NSImage(size: destSize)
        let rect = NSRect(x: 0, y: 0, width: w, height: h)
        newImage.lockFocus()
        image.draw(in: rect)
        newImage.unlockFocus()
        return newImage
    }
    
    func nsImageToBitmap(_ image:NSImage)->NSBitmapImageRep{
        let cgImgRef = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        let bmpImgRef = NSBitmapImageRep(cgImage: cgImgRef!)
        return bmpImgRef
    }
    
    func bitmapToPngData(_ image:NSBitmapImageRep)->Data{
        return (image.representation(using: .png, properties: [:]))!
    }
    
    func dataToFile(_ image_data: Data)->NSString{
        var pathstr: NSString = self.img_path1
        
        if self.path_switch{
            pathstr = self.img_path2
        }
        
        let path = URL(fileURLWithPath: pathstr as String)
        
        do{
            try image_data.write(to: path)
        } catch{
            print("Error with image")
        }
        return pathstr
    }
    
    func setDesktop(_ pathstr:NSString){
        self.MusicBridge.setDesktop(pathstr)
        self.path_switch = !self.path_switch
    }
    
    func generateBackgroundColorImage(size:(Int, Int), color:NSColor) -> NSImage{
        let bg = NSImage(size: NSSize(width: size.0, height: size.1))
        let rect = NSRect(x: 0, y: 0, width: size.0, height: size.1)
        
        bg.lockFocus()
        color.drawSwatch(in: rect)
        bg.unlockFocus()
        return bg
    }
    
    func overlayImages(source:NSImage, destination: NSImage)->NSImage{
        let width = destination.size.width
        let height = destination.size.height
        
        let image_dim = height/CGFloat(self.image_scale_in_bg)
        let centre_x = CGFloat((width - image_dim)/2)
        let centre_y = CGFloat((height - image_dim)/2)
        
        let rect = NSRect(x: centre_x, y: centre_y, width: image_dim, height: image_dim)
        
        destination.lockFocus()
        source.draw(in: rect)
        destination.unlockFocus()
        
        return destination
        
    }
    
    func imageToPixel(image: NSImage)->[Vector]{

        let swiftImage = nsImageToBitmap(image)
        let width = Int(swiftImage.size.width)
        let height = Int(swiftImage.size.height)

        var pixelArray:[Vector] = []

        for x in (0...width-1){
            for y in (0...height-1){
                var tempArray:[Double] = []
                let color = swiftImage.colorAt(x: x, y: y)!
                tempArray.append(Double(color.redComponent*255))
                tempArray.append(Double(color.greenComponent*255))
                tempArray.append(Double(color.blueComponent*255))
                pixelArray.append(Vector(tempArray))

            }
        }
        return pixelArray
    }
    
    func DominantColorKMeans(pixelArray: [Vector])->NSColor{
        let kmm = KMeans<Int>(labels: [1, 2, 3, 4])
        kmm.trainCenters(pixelArray, convergeDistance: 0)
    
        let mostDominantIndex = kmm.centroidsCount.firstIndex(of: kmm.centroidsCount.max()!)!
        //value is 0-indexed
        let mostDominantPixel = kmm.centroids[mostDominantIndex].data
        let color = NSColor(red: mostDominantPixel[0]/255, green: mostDominantPixel[1]/255, blue: mostDominantPixel[2]/255, alpha: 1.0)
        return color
    }

}




