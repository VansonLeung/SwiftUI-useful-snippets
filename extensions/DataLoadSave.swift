import Foundation

extension Data {

    func write(withName name: String) -> URL {

        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
        do {
            print("DataLoadSave -> write ... \(name)")
            try write(to: url, options: .atomicWrite)
        } catch (let error) {
            print("DataLoadSave -> write ... \(name) [FAIL] \(error.localizedDescription)")
        }
        return url
    }
    
    static func read(withName name: String) -> Data? {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
        do {
            print("DataLoadSave -> read ... \(name)")
            let data = try Data(contentsOf: url)
            if data != nil
            {
                print("DataLoadSave -> read ... \(name) [GOOD, EXISTING]")
            }
            else
            {
                print("DataLoadSave -> read ... \(name) [NON-EXIST]")
            }
            return data
        } catch (let error) {
            print("DataLoadSave -> read ... \(name) [FAIL] \(error.localizedDescription)")
        }
        return nil
    }
}
