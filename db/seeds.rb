CoachUser.create first_name: 'Admin', last_name: 'Admin', password: '12345678',
                 email: 'user@example.com'

### Creates Initial questionnaires

title = %Q(Attivita' Fisica)
question_hash = {
    %Q(Qual'è la tua attività preferita di sport tra quelle indicate?) => ["ciclismo","nuoto","corsa", "yoga", "danza", "sport di squadra", "camminata", "altro", "non ho uno sport preferito"],
    %Q(Quanto spesso ti eserciti?) => ["Quasi mai","3 o più volte in settimana","1/2 volte in settimana"],
    %Q(Con che intensità ti eserciti?) => ["tranquilla","media", "ci vado pesante", "non mi esercito"],
    %Q(Il tuo lavoro richiede stare seduti o essere in movimento?) => ["muoversi", "stare seduti", "entrambe"],
    %Q(Quanto spesso vai in bici o a piedi?) => ["a volte","raramente","spesso"]
}

questionnaire = Questionnaire.create(title: title, initial: true)

question_hash.each { |key, value|
  question = questionnaire.questionnaire_questions.create(text: key)
  value.each { |e|
    question.options.create(text: e)
  }
}


title = %Q(Salute)
question_hash = {
    %Q(Se dovessi dare un voto da 1(insufficiente) a 5(ottimo) come valuteresti complessivamente la tua salute?) => ["1","2","3", "4", "5"],
    %Q(Cosa significano per te benessere e salute?) => ["mangiare bene","essere attivi","sentirsi rilassati", "avere un buon aspetto", "non lo so"],
    %Q(Come definiresti le tue abitudini alimentari?) => ["super sane","abbastanza buone", "normali", "bisogno di una regolata", "codice rosso"],
    %Q(Mi potresti dire quanta acqua bevi al giorno?) => ["meno di 1 L", "tra 1 e 1.5 L", "tra 1.5 e 2 L", "più di 2L"],
    %Q(Quanta frutta e verdura mangi al giorno?) => ["meno di 2 frutti/verdure","tra 2 e 4 frutti/verdure","più di 4 frutti/verdure"],
    %Q(Come è il tuo livello di energia?) => ["basso","medio","alto"],
    %Q(Quale è il tuo orario migliore durante la mattina per ricevere le notifiche sulle attività?) => ["7 AM", "8 AM","9 AM","10 AM"],
    %Q(Quale è il tuo orario migliore durante la sera per ricevere le notifiche sulle attività?) => ["7 PM", "8 PM","9 PM","10 PM"]
}

questionnaire = Questionnaire.create(title: title, initial: true)

question_hash.each { |key, value|
  question = questionnaire.questionnaire_questions.create(text: key)
  value.each { |e|
    question.options.create(text: e)
  }
}


title = %Q(Coping)
question_hash = {
    %Q(Come valuteresti la quantità di stress nella tua vita?) => ["per niente stressato","poco stressato","molto stressato"],
    %Q(E quante ore dormi la notte?) => ["meno di 5 h","5/6 h","6/7 h", "piu' di 8 h"],
    %Q(Come è il tuo livello di energia durante il giorno?) => ["basso","normale", "alto"]
}

questionnaire = Questionnaire.create(title: title, initial: true)

question_hash.each { |key, value|
  question = questionnaire.questionnaire_questions.create(text: key)
  value.each { |e|
    question.options.create(text: e)
  }
}


title = %Q(Salute Mentale)
question_hash = {
    %Q(Quanto spesso ti sei sentito nervoso negli ultimi 30 giorni?) => ["mai","poche volte","a volte", "spesso", "sempre"],
    %Q(Negli ultimi 30 giorni, quanto spesso ti sei sentito così depresso che niente ti poteva tirare su il morale?) => ["mai","poche volte","a volte", "spesso", "sempre"],
    %Q(E quanto spesso ti sei sentito indegno o senza valore?) => ["mai","poche volte","a volte", "spesso", "sempre"],
    %Q(Durante gli ultimi 30 giorni, circa quanto spesso ti sei sentito come se tutto fosse una fatica?) => ["mai","poche volte","a volte", "spesso", "sempre"]

}

questionnaire = Questionnaire.create(title: title, initial: true)

question_hash.each { |key, value|
  question = questionnaire.questionnaire_questions.create(text: key)
  value.each { |e|
    question.options.create(text: e)
  }
}

### Just some testing questionnaires

=begin
title = %Q(Q1)
question_hash = {
    %Q(Qual'è la tua attività preferita di sport tra quelle indicate?) => ["ciclismo","nuoto","corsa", "yoga", "danza", "sport di squadra", "camminata", "altro", "non ho uno sport preferito"],
    %Q(Quanto spesso ti eserciti?) => ["Quasi mai","3 o più volte in settimana","1/2 volte in settimana"]
}

questionnaire = Questionnaire.create(title: title, initial: true)

question_hash.each { |key, value|
  question = questionnaire.questionnaire_questions.create(text: key)
  value.each { |e|
    question.options.create(text: e)
  }
}

title = %Q(Q2)
question_hash = {
    %Q(Qual'è la tua attività preferita di sport tra quelle indicate?) => ["ciclismo","nuoto","corsa", "yoga", "danza", "sport di squadra", "camminata", "altro", "non ho uno sport preferito"],
    %Q(Quanto spesso ti eserciti?) => ["Quasi mai","3 o più volte in settimana","1/2 volte in settimana"]
}

questionnaire = Questionnaire.create(title: title, initial: true)

question_hash.each { |key, value|
  question = questionnaire.questionnaire_questions.create(text: key)
  value.each { |e|
    question.options.create(text: e)
  }
}
=end