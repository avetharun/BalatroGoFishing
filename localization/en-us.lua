return {
    
    Other = {
        bgf_harpy_forager = {
            name = "Forager Card:",
            text = {
                "Will create a {C:fruit}Fruit{} Card",
                "and add it to the Deck.",
                "Consuming a Fruit Card",
                "this way will destroy it."
            }
        },
        fruit_use = {
            name = 'Eat',
            text = {
            }
        },
    },
    descriptions = {
        Enhanced = {
            m_bgf_fruit = {
                name = 'Fruit',
                text = {
                    "Can be fed to a {C:harpy}Harpy{} to gain {C:red}+#4# {} Mult for 5 blinds.",
                    "Can only be played as a High Card",
                    "{X:red,C:white}+#1# {} Mult",
                    "{X:chips,C:white}+#2# {} Chips",
                    "#3#"
                }
            },
        },
        FishingRod = {
            r_bgf_rod_basic = {
                name="Fishing Fishing Rod",
                text = {
                    "Standard fishing rod.",
                    "No bonuses, no drawbacks."
                }
            },
            r_bgf_rod_reinforced = {
                name="Reinforced Fishing Rod",
                text = {
                    "Slightly higher weight capability",
                    "but takes longer to reel in."
                }
            },
            r_bgf_rod_fiberglass = {
                name="Fiberglass Fishing Rod",
                text = {
                    "Slightly higher weight capability",
                    "and is very fast, but hard to control."
                }
            },
            r_bgf_rod_carbon = {
                name="Carbon Fishing Rod",
                text = {
                    "High weight capability",
                    "and increased caught fish weight,",
                    "but is heavy."
                }
            },
            r_bgf_rod_steel = {
                name="Steel Fishing Rod",
                text = {
                    "High weight capability",
                    "Slightly increased caught fish weight,",
                    "but is heavy."
                }
            },
            r_bgf_rod_hypersteel = {
                name="HyperSteel Fishing Rod",
                text = {
                    "Very high weight capability",
                    "Slightly increased caught fish weight,",
                    "but is very heavy and slow."
                }
            },
        },
        Baits = {
            b_bgf_bait_forbidden = {
                name = "Forbidden Bait(?)",
                text = {
                    "You don't want to know what's in this."
                }
            },
            b_bgf_bait_legendary = {
                name = "Dragonscale Bait",
                text = {
                    "How does a fish even eat this??"
                }
            },
            b_bgf_bait_strawberry = {
                name = "Strawberry Wafer Cookie",
                text = {
                    "You're more likely to eat this than a fish."
                }
            },
            b_bgf_bait_cheese = {
                name = "Cheese",
                text = {
                    "Fish aren't rodents!"
                }
            },
            b_bgf_bait_stellaron = {
                name = "Stellaron",
                text = {
                    "Mysterious space thing",
                    "{s:0.8}Someone call {C:herta,s:0.8}Herta{}!"
                }
            },
            b_bgf_bait_worm = {
                name = "Worm",
                text = {
                    "Completely Normal Bait*",
                    "{s:0.6}* It's very spicy.",
                }
            },
        },
        Fishies = {

            f_bgf_salmon = { name = "Salmon", text = {"Reel good time!","Weight: #1#kg","#2#"}} ,
            f_bgf_bass = { name = "Bass", text = {"Drop the bass!","Weight: #1#kg","#2#"}},
            f_bgf_shrimp = { name = "Shrimp", text = {"A little too shrimpy for you?","Weight: #1#kg","#2#"}},
            f_bgf_cod = { name = "Cod", text = {"My Cod! It's Jimbo!","Weight: #1#kg","#2#"}},
            f_bgf_tuna = { name = "Tuna", text = {"Tuna in later!","Weight: #1#kg","#2#"}},
            f_bgf_catfish = { name = "Catfish", text = {"Pawsitively fin-tastic!","Weight: #1#kg","#2#"}},
            f_bgf_trout = { name = "Trout", text = {"Holy trout!","Weight: #1#kg","#2#"}},
            f_bgf_pike = { name = "Pike", text = {"Take a pike!","Weight: #1#kg","#2#"}},
            f_bgf_perch = { name = "Perch", text = {"Perch-fection!","Weight: #1#kg","#2#"}},
            f_bgf_shark = {name = "Shark", text = {"Ultrakill reference, Ikea reference, you choose!","Weight: #1#kg","#2#"}},
            f_bgf_size2 = {name = "Size 2 Fish", text = {"Okay this one's an Ultrakill reference.","Size: 2","#2#"}},
        },
        Tarot ={
            c_bgf_fruit_tree = {
                name = "Tree of Life",
                text = {"Converts up to two cards to {C:fruit}Fruit{} cards."}
            },
        },
        Joker = {
            j_bgf_basic_bait = {name = "Basic Bait", text = {"Standard bait. Nothing special."}},
            j_bgf_harpy = {
                name = 'Harpy',
                text = {
                    "Eat a {C:fruit}Fruit card{} or {C:food}Food Joker{} to gain {C:red}Mult{}.",
                    "Will reset after #2# blinds.",
                    "Currently {C:red}+#1#{} Mult.",
                    " ",
                    "{s:0.8}Eating a Food Joker will give {C:red,s:0.8}4x{} sell value to {C:red,s:0.8}Mult{}.",
                    "Upon Boss Blind completion, you can {C:bgf_fish}Fish{} for a {C:food}Food{} Card.",
                }
            },
            
        }
    },
    misc = {
        bgf_fish_weights = {
        },
        bgf_credits = {
            shark_image = "ShadowTheDragonCat"
        },
        bgf_fish = {
        },
        challenge_names = {
            m_bgf_harpy_challenge = "Thick Forest"
        },
        dictionary = {
            bgf_cannot_sell="Cannot be sold",
            bgf_rod_tooltip_weight_xmult="XWeight: %s",
            bgf_rod_tooltip_weight_max="Max Weight: %s",
            bgf_rod_tooltip_heaviness="Heaviness: %s",
            bgf_rod_tooltip_speed="Reel Speed: %s",
            bgf_rod_tooltip_fish_weight_addtl="Fish Weight: %s",
            bgf_bait_tooltip_attraction="Follow Rate: %s",
            bgf_bait_tooltip_linger_time="Hook Time: %s",
            bgf_fish = "Fish",
            bgf_rod = "Rod",
            bgf_bait = "Bait",
            b_bgf_fishie_baits = "Bait",
            b_bgf_fishies = "Fishies",
            b_bgf_fishie_rods = "Fishing Rods",
            b_bgf_drop_to_equip = "Drop to Equip",
            bgf_fish_get = "Fish Get!",
            bgf_fish_aborted = "Fishing Stopped :(",
            bgf_fish_could_not_start = "Cannot fish!",
            bgf_no_fish = "No fish caught!",
            bgf_no_rod = "No Fishing Rod equipped!",
            bgf_fish_type = "Fish type: ",
            bgf_fish_weight = "Fish Weight: ",
            bgf_fish_size = "Fish Size: ",
            b_bgf_stat_reset = "Reset!",
            b_eat = 'Eat',
            b_fruit_use = 'Feed to Harpy',
            e_fruit_card_edible = 'Edible',
            e_fruit_card_inedible = 'Inedible for %d hands.',
            bgf_w_tiny = "Tiny",
            bgf_w_b_average = "Below Average",
            bgf_w_average = "Average",
            bgf_w_big = "Big",
            bgf_w_large = "Large",
            bgf_w_massive = "Massive",
            bgf_w_colossal = "Colossal",
            bgf_uncaught = "Uncaught",
            bgf_shop_required = "Must be in Run Shop to sell.",
        },
        v_text = {
            
            ch_c_m_bgf_harpy_challenge1={
                "{C:attention}Card-Modifying {C:tarot}Tarots {C:attention}and {C:spectral}Spectral {C:attention}Cards{} will not appear.",
            },
            ch_c_m_bgf_harpy_challenge2={
                "Start with {C:attention}5{} {C:fruit}Fruit Cards{}",
            },
            ch_c_m_bgf_harpy_challenge3={
                "{s:0.9}These {s:0.9,C:fruit}Fruit Cards{s:0.9} will not be destroyed by The Harpy"
            }
        },
    }
}