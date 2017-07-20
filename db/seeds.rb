CoachUser.create first_name: 'Admin', last_name: 'Admin', password: '12345678',
                 email: 'user@example.com'

User.create first_name: 'Gianni', last_name: 'Morandi',
            email: 'gianni.morandi@io.io', bot_command_data: '{}', cellphone: '3405124000'
User.create first_name: 'Maria', last_name: 'Giovanna',
            email: 'maria.morandi@io.io', bot_command_data: '{}', cellphone: '3405123400'

Activity.create name: 'Corsa leggera', desc: 'Corsa tranquilla, preferibilmente non su asfalto ma su terra',
                a_type: 'weekly', category: 'physical', n_times: 2

Plan.create name: 'Benessere a sforzo zero', desc: 'Un piano che non richiede sforzo ma cheporta un migliardo di benefici',
            from_day: '20/07/2017', to_day: '20/08/2017', coach_user_id: 1

