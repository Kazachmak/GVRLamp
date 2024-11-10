import Foundation

public final class Effect {
  // текущие значения
  var bright: Int?
  var speed: Int?
  var scale: Int?
  
  let name: String
  let id: Int
  let str: String
  
  var maxSpeed: Int {
    guard
      str.components(separatedBy: ",").count > 2,
      let speed = Int(str.components(separatedBy: ",")[2])
      else {
        return 255
      }
    return speed
  }
  
  var minSpeed: Int {
    guard
      str.components(separatedBy: ",").count > 1,
      let speed = Int(str.components(separatedBy: ",")[1])
      else {
        return 0
      }
     return speed
  }
  
  var maxScale: Int {
    guard
      str.components(separatedBy: ",").count > 4,
      let scale = Int(str.components(separatedBy: ",")[4])
      else {
        return 255
      }
      return scale
  }
  
  var minScale: Int {
    guard
      str.components(separatedBy: ",").count > 3,
      let scale = Int(str.components(separatedBy: ",")[3])
      else {
        return 0
      }
    return scale
  }
  
  var speedRange: Int {
    return maxSpeed - minSpeed == 0 ? 100 : maxSpeed - minSpeed
  }
  
  var scaleRange: Int {
    return maxScale - minScale == 0 ? 100 : maxScale - minScale
  }
  
  init(_ str: String) {
    self.name = str.components(separatedBy: ",")[0].components(separatedBy: ".")[1]
    self.id = Int(str.components(separatedBy: ",")[0].components(separatedBy: ".")[0]) ?? 0
    self.str = str
  }
}
