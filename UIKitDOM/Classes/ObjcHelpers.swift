// Obj-C cannot represent an optional bool, but we can use an NSNumber with
// values 0 and 1 instead.
// https://stackoverflow.com/a/30723432/5951226
// https://nshipster.com/bool/
typealias OptionalBool = NSNumber
