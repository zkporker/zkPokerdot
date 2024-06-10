module game::room{

    use sui::object::UID;
    use sui::event::Self;
    use std::string::{Self,String};
    use std::debug::print;

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
        creator:address,
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


        let sender = tx_context::sender(ctx);
        let room_name = string::utf8(room_name);
        let creator = string::utf8(player_name);
        let room = Room{
            id,
            room_name,
            creator:sender,
            players:option::none(),
        };

        let oid = object::id(&room);

        transfer::public_share_object(room);

        event::emit(GameCreated{id:oid,room_name,creator});
    }


    // join game
    public fun join_game( room: &mut Room,playername:vector<u8>,ctx:&mut TxContext){
        // Account calling this dispatchable.
        let player = tx_context::sender(ctx);
        // let game_id = room.id;
        // get the accounts of room
        let mut accounts = room.players;

        if(accounts.is_none()){
            let mut players:vector<address> = std::vector::empty<address>();
            std::vector::push_back(&mut players,player);
            std::option::fill(&mut accounts,players);
            room.players = accounts;
        }else{
            let players = accounts.borrow_mut<vector<address>>();
            // make sure the amount of user less than 3
            assert!(players.length()<PLAYER_COUNT,EUserEnghou);
            // check the user has join game.
            assert!(!players.contains(&player),EUserInRoom);
            // add the player to the room
            players.push_back(player);
        };

        event::emit(PlayerJoinRoom{
            room_id:object::uid_to_inner(&room.id),
            player,
        });
    }

    #[test_only]
    use sui::test_scenario as ts;
    #[test_only]
    use std::string::bytes;
    #[test_only]
    use std::debug::{Self};
    #[test_only]
    const ADMIN:address = @0xAD;
    #[test_only]
    const ALICE:address = @0xA;
    #[test_only]
    const BOB:address = @0xB;


    #[test]
    fun test_create_room(){
        let mut scenario = ts::begin(@0x0);
        let room_name = b"room1";
        {
            ts::next_tx(&mut scenario, ADMIN);
            create_game(room_name,b"csloud",ts::ctx(&mut scenario));
            ts::next_tx(&mut scenario, ADMIN);
            let room:Room = ts::take_shared(&scenario);
            ts::next_tx(&mut scenario, ADMIN);
            assert!(room.creator == ADMIN,1);
            assert!(*bytes(&room.room_name)==b"room1",2);
            assert!(room.players.is_none(),3);
            ts::return_shared(room);
        };
        ts::end(scenario);
    }

    #[test]
    fun test_join_game(){
        let mut scenario = ts::begin(@0x0);
        let room_name = b"room1";
        {
            ts::next_tx(&mut scenario,ADMIN);
            create_game(room_name,b"csloud",ts::ctx(&mut scenario));
            ts::next_tx(&mut scenario, ALICE);
            let mut room:Room = ts::take_shared(&scenario);
            join_game(&mut room,b"cloud",ts::ctx(&mut scenario));
            ts::return_shared(room);
        };
        ts::end(scenario);
    }

    #[test]
    fun test_over_join_game(){
        let mut scenario = ts::begin(@0x0);
        let room_name = b"room1";
        {
            ts::next_tx(&mut scenario,ADMIN);
            create_game(room_name,b"csloud",ts::ctx(&mut scenario));
            ts::next_tx(&mut scenario, ALICE);
            let mut room:Room = ts::take_shared(&scenario);
            join_game(&mut room,b"Alice",ts::ctx(&mut scenario));
            ts::return_shared(room);
            ts::next_tx(&mut scenario, BOB);
            let mut room:Room = ts::take_shared(&scenario);

            assert!(std::option::is_some(&room.players),3);
            join_game(&mut room,b"Bob",ts::ctx(&mut scenario));
            ts::return_shared(room);
        };
        ts::end(scenario);
    }
}