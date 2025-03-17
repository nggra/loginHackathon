import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Text "mo:base/Text";

actor UserManager {
    
    type User = {
        username: Text;
        password: Text;
    };

    // Stable storage untuk menyimpan data user agar tetap ada saat upgrade canister
    stable var userBuffer: [(Text, User)] = [];

    // Deklarasi HashMap tanpa fromIter langsung
    var users: HashMap.HashMap<Text, User> = HashMap.HashMap<Text, User>(
        10, Text.equal, Text.hash
    );

    // Inisialisasi ulang users dari userBuffer (agar kompatibel dengan tipe)
    system func preupgrade() {
        userBuffer := Iter.toArray(users.entries());
    };

    system func postupgrade() {
        users := HashMap.fromIter<Text, User>(
            Iter.fromArray(userBuffer),
            10,
            Text.equal,
            Text.hash
        );
    };

    // Fungsi untuk registrasi user
    public func register(username: Text, password: Text): async Text {
        if (users.get(username) != null) {
            return "⚠️ Username sudah terdaftar!";
        };

        let newUser: User = { username = username; password = password };
        users.put(username, newUser);

        return "✅ Registrasi berhasil!";
    };

    // Fungsi untuk login
    public func login(username: Text, password: Text): async Text {
        switch (users.get(username)) {
            case (null) { return "❌ User tidak ditemukan!"; };
            case (?user) {
                if (user.password == password) {
                    return "✅ Login sukses!";
                } else {
                    return "❌ Password salah!";
                };
            };
        };
    };

    // Fungsi untuk mengecek apakah user sudah terdaftar
    public func isUserExists(username: Text): async Bool {
        return users.get(username) != null;
    };
};
