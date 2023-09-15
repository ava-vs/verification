    import Map "mo:base/HashMap";
import Principal "mo:base/Principal";

    module {
        public type DocId = Nat;

        public type Document = {
        docId : DocId;
        tags : [ Text ];
        content : Text;
        imageLink : Text; //(link to asset canister)

    };

    public type UserDocuments = Map.HashMap<Principal, [DocId]>;

    public type Branch = Nat8;

    public type DocumentHistory = {
        docId : DocId;
        timestamp : Nat;
        changedBy : Principal;
        value : Int;
        comment : Text;
    };

    public type Tag = Text;

     public type ApiError = {
    #Unauthorized;
    #InvalidTokenId;
    #ZeroAddress;
    #NoNFT;
    #Other;
  };

  public type Result<S, E> = {
    #Ok : S;
    #Err : E;
  };

  public type Change = (Principal, Branch, Int);

  public type ChangeResult = Result<Change, ApiError>;

  public type SharedResult = Result<Change, ApiError>;

}
