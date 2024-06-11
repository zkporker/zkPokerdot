module game::room{

    use sui::object::UID;
    use sui::event::Self;
    use std::string::{Self,String};
    use std::debug::print;
    use sui::tx_context;

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
        let accounts = &mut room.players;

        if(accounts.is_none()){
            let mut players:vector<address> = std::vector::empty<address>();
            std::vector::push_back(&mut players,player);
            std::option::fill(accounts,players);
            // room.players = accounts;
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

    // shuffle post card
    public fun shuffle( room: &mut Room,cards: vector<u32>,ctx:&mut tx_context)  {
    let gamer = tx_context::sender(ctx);
    // GameDecks::<T>::insert(&game_id, cards.clone());
    // // 更新存储中的状态
    // PlayerStatus::<T>::insert(game_id, gamer, 1);
    // //判断是否三位玩家都准备
    // let mut count = 0;
    // for _ in PlayerStatus::<T>::iter_prefix(game_id) {
    // count += 1;
    // }
    // if count == 3 {
    // if GameState::<T>::get(&game_id) == 2{
    // return Err(Error::<T>::GameStarted.into())
    // }
    // GameState::<T>::insert(&game_id, 2);
    // // 如果找到3条数据则可以开始发牌
    // // 人数已满，游戏状态设为进行中
    // // 按顺序发牌给三个玩家
    // let mut player1_cards = Vec::new();
    // let mut player2_cards = Vec::new();
    // let mut player3_cards = Vec::new();
    //
    // // 留下的三张底牌
    // let mut remaining_cards = Vec::new();
    //
    // // 分发牌给每位玩家
    // for (index, &card) in cards.iter().enumerate() {
    // match index {
    // 0..=16 => player1_cards.push(card),  // 第一位玩家的牌
    // 17..=33 => player2_cards.push(card), // 第二位玩家的牌
    // 34..=50 => player3_cards.push(card), // 第三位玩家的牌
    // _ => remaining_cards.push(card),     // 底牌
    // }
    // }
    //
    // // 存储玩家的牌
    // let accounts = GamePlayers::<T>::get(&game_id);
    // PlayerCards::<T>::insert(&accounts[0], player1_cards);
    // PlayerCards::<T>::insert(&accounts[1], player2_cards);
    // PlayerCards::<T>::insert(&accounts[2], player3_cards);
    //
    // // 存储底牌
    // BottomCards::<T>::insert(&game_id, remaining_cards);
    //
    // Self::deposit_event(Event::PlayerAllPrepared);
    // }
    //
    // Ok(().into())
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
    #[test_only]
    const CHALIE:address = @0xC;
    #[test_only]
    const DAVE:address = @0xD;
    #[test_only]
    const EVA:address = @0xe;


    #[test]
    fun test_create_game(){
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
            join_game(&mut room,b"Alice",ts::ctx(&mut scenario));
            // ts::return_shared(room);
            ts::next_tx(&mut scenario, BOB);
            // let mut room:Room = ts::take_shared(&scenario);

            assert!(std::option::is_some(&room.players),1);
            assert!(std::option::borrow(&room.players).length()==1,2);
            join_game(&mut room,b"Bob",ts::ctx(&mut scenario));
            ts::next_tx(&mut scenario, CHALIE);
            assert!(std::option::borrow(&room.players).length()==2,3);
            join_game(&mut room,b"Chalie",ts::ctx(&mut scenario));
            ts::next_tx(&mut scenario, DAVE);
            assert!(std::option::borrow(&room.players).length()==3,4);
            ts::return_shared(room);
        };
        ts::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = EUserEnghou)]
    fun test_over_join_game(){
        let mut scenario = ts::begin(@0x0);
        let room_name = b"room1";
        {
            ts::next_tx(&mut scenario,ADMIN);
            create_game(room_name,b"csloud",ts::ctx(&mut scenario));
            ts::next_tx(&mut scenario, ALICE);
            let mut room:Room = ts::take_shared(&scenario);
            join_game(&mut room,b"Alice",ts::ctx(&mut scenario));
            // ts::return_shared(room);
            ts::next_tx(&mut scenario, BOB);
            // let mut room:Room = ts::take_shared(&scenario);

            assert!(std::option::is_some(&room.players),1);
            assert!(std::option::borrow(&room.players).length()==1,2);
            join_game(&mut room,b"Bob",ts::ctx(&mut scenario));
            ts::next_tx(&mut scenario, CHALIE);
            assert!(std::option::borrow(&room.players).length()==2,3);
            join_game(&mut room,b"Chalie",ts::ctx(&mut scenario));
            ts::next_tx(&mut scenario, DAVE);
            assert!(std::option::borrow(&room.players).length()==3,4);
            join_game(&mut room,b"dave",ts::ctx(&mut scenario));
            ts::return_shared(room);
        };
        ts::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = EUserInRoom)]
    fun test_repeat_join_game(){
        let mut scenario = ts::begin(@0x0);
        let room_name = b"room1";
        {
            ts::next_tx(&mut scenario,ADMIN);
            create_game(room_name,b"csloud",ts::ctx(&mut scenario));
            ts::next_tx(&mut scenario, ALICE);
            let mut room:Room = ts::take_shared(&scenario);
            join_game(&mut room,b"Alice",ts::ctx(&mut scenario));

            ts::next_tx(&mut scenario, ALICE);
            assert!(std::option::is_some(&room.players),1);
            assert!(std::option::borrow(&room.players).length()==1,2);
            join_game(&mut room,b"Alice2",ts::ctx(&mut scenario));
            ts::return_shared(room);

        };
        ts::end(scenario);
    }


}