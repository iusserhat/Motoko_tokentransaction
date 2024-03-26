import Icrc1Ledger "canister:icrc1_ledger_canister";
import Debug "mo:base/Debug";
import Result "mo:base/Result";
import Option "mo:base/Option";
import Blob "mo:base/Blob";
import Error "mo:base/Error";

actor {
  // Hesap tipi tanımı, sahibi ve opsiyonel bir alt hesap numarası içerir.
  type Account = {
    owner: Principal;
    subaccount: ?[Nat8];
  };

  // Transfer işlemi için argümanlar.
  type TransferArgs = {
    amount: Nat;
    toAccount: Account;
  };

  // Transfer işlemi gerçekleştiren fonksiyon.
  public shared ({caller}) func transfer(args: TransferArgs): async Result.Result<Icrc1Ledger.BlockIndex, Text> {
    // İşlem detaylarını debug çıktısı olarak ver.
    Debug.print("Transferring " # Debug.debug_show(args.amount) # " tokens to account " # Debug.debug_show(args.toAccount));

    // Transfer işlemi için gerekli argümanlar.
    let transferArgs: Icrc1Ledger.TransferArg = {
      memo: null, // İşlemi ayırt etmek için kullanılabilir.
      amount: args.amount, // Transfer edilecek miktar.
      from_subaccount: null, // Canister'ın varsayılan alt hesabından transfer yapılacak.
      fee: null, // Belirtilmezse, canister için varsayılan ücret kullanılır.
      to: args.toAccount, // Tokenlerin transfer edileceği hesap.
      created_at_time: null, // İşlem zamanı; belirtilmezse, mevcut ICP zamanına ayarlanır.
    };

    try {
      // Transfer işlemini başlat.
      let transferResult = await Icrc1Ledger.icrc1_transfer(transferArgs);

      // Transfer sonucunu değerlendir.
      switch (transferResult) {
        case (#err(transferError)): {
          return #err("Couldn't transfer funds:\n" # Debug.debug_show(transferError));
        };
        case (#ok(blockIndex)): {
          return #ok(blockIndex);
        };
      };
    } catch (error: Error) {
      // Transfer sırasında oluşabilecek hataları yakala.
      return #err("Reject message: " # Error.message(error));
    };
  };
};

