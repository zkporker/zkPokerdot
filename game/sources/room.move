module game::room{

    use sui::object::UID;
    use sui::transfer::{Self};
    use sui::event::Self;
    use std::string::{Self,String};

    const PLAYER_COUNT:u64 = 3;

    // errors
    const EUserEnghou:u64 = 0;
    const EUserInRoom:u64 = 1;

    public struct Game has key,store{
        id:UID,
    }

    public struct Room has key,store{
        id:UID,
        room_name:String,
        creator:String,
        players:Option<vector<address>>
    }

    public struct GameCreated has copy,drop{
        id:ID,
        room_name:String,
        creator:String,
    }

    public struct PlayerJoinRoom has copy,drop{
        room_id:ID,
        player:address,
    }

    // create room
    public fun create_game(room_name:vector<u8>,player_name:vector<u8>,ctx: &mut TxContext,){
        let id = object::new(ctx);
        let oid = object::uid_to_inner(&id);

        let sender = tx_context::sender(ctx);
        let room_name = string::utf8(room_name);
        let creator = string::utf8(player_name);
        let room = Room{
            id,
            room_name,
            creator,
            players:option::none(),
        };

        transfer::public_share_object(room);

        event::emit(GameCreated{id:oid,room_name,creator});
    }


    // join game
    public fun join_game( room: &mut Room,playername:vector<u8>,ctx:&mut TxContext){
        // Account calling this dispatchable.
        let gamer = tx_context::sender(ctx);
        // let game_id = room.id;
        // get the accounts of room
        let mut accounts = room.players;


        let players = accounts.borrow_mut<vector<address>>();
        // make sure the amount of user less than 3
        assert!(players.length()<PLAYER_COUNT,EUserEnghou);
        // check the user has join game.
        assert!(players.contains(&gamer),EUserInRoom);
        // add the player to the room
        players.push_back(gamer);
        event::emit(PlayerJoinRoom{
            room_id:object::uid_to_inner(&room.id),
            player:gamer,
        });
    }

    
}