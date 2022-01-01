if Meteor.isClient
    Router.route '/event/:doc_id/view', (->
        @layout 'layout'
        @render 'event_view'
        ), name:'event_view'
        
    Router.route '/events', (->
        @layout 'layout'
        @render 'events'
        ), name:'events'
        
        
        
        
    # Router.route '/e/:doc_slug/', (->
    #     @layout 'layout'
    #     @render 'event_view'
    #     ), name:'event_view_by_slug'
        
    Template.registerHelper 'facilitator', () ->    
        Meteor.users.findOne @facilitator_id
    Template.registerHelper 'fac', () ->    
        Meteor.users.findOne @facilitator_id
   
    Template.registerHelper 'my_ticket', () ->    
        event = Docs.findOne @_id
        Docs.findOne
            model:'transaction'
            transaction_type:'ticket_purchase'
            event_id:@_id
            _author_id:Meteor.userId()
   
    Template.registerHelper 'event_room', () ->
        event = Docs.findOne @_id
        Docs.findOne 
            _id:event.room_id

    Template.registerHelper 'going', () ->
        event = Docs.findOne @_id
        event_tickets = 
            Docs.find(
                model:'transaction'
                transaction_type:'ticket_purchase'
                event_id: @_id
                ).fetch()
        going_user_ids = []
        for ticket in event_tickets
            going_user_ids.push ticket._author_id
        Meteor.users.find 
            _id:$in:going_user_ids
            
    Template.registerHelper 'maybe_going', () ->
        event = Docs.findOne @_id
        Meteor.users.find 
            _id:$in:event.maybe_user_ids
    Template.registerHelper 'not_going', () ->
        event = Docs.findOne @_id
        Meteor.users.find 
            _id:$in:event.not_user_ids

    Template.registerHelper 'event_tickets', () ->
        Docs.find 
            model:'transaction'
            transaction_type:'ticket_purchase'
            event_id: Router.current().params.doc_id

        
    Template.events.onCreated ->
        @autorun => Meteor.subscribe 'events',
            Session.get('viewing_room_id')
            Session.get('viewing_past')
        @autorun => Meteor.subscribe 'model_docs', 'badge'
        @autorun => Meteor.subscribe 'model_docs', 'room'
        # @autorun => Meteor.subscribe 'model_docs', 'transaction'
        
    Template.events.events
        'click .toggle_past': ->
            Session.set('viewing_past', !Session.get('viewing_past'))
        'click .select_room': ->
            if Session.equals('viewing_room_id', @_id)
                Session.set('viewing_room_id', null)
            else
                Session.set('viewing_room_id', @_id)
        'click .add_event': ->
            new_id = 
                Docs.insert 
                    model:'event'
                    published:false
                    # purchased:false
            Router.go "/event/#{new_id}/edit"
            
            
    Template.events.helpers
        rooms: ->
            Docs.find 
                model:'room'
                
        room_button_class: -> 
            if Session.equals('viewing_room_id', @_id) then 'blue' else 'basic'
        viewing_past: -> Session.get('viewing_past')
        events: ->
            # console.log moment().format()
            if Session.get('viewing_past')
                Docs.find {
                    model:'event'
                    published:true
                    date:$lt:moment().subtract(1,'days').format("YYYY-MM-DD")
                }, 
                    sort:start_datetime:-1
            else
                Docs.find {
                    model:'event'
                    published:true
                    date:$gt:moment().subtract(1,'days').format("YYYY-MM-DD")
                }, 
                    sort:date:1
    
    
        can_add_event: ->
            facilitator_badge = 
                Docs.findOne    
                    model:'badge'
                    slug:'facilitator'
            if facilitator_badge
                Meteor.userId() in facilitator_badge.badger_ids
            
    
    

if Meteor.isServer
    Meteor.publish 'future_events', ()->
        console.log moment().subtract(1,'days').format("YYYY-MM-DD")
        Docs.find {
            model:'event'
            published:true
            date:$gt:moment().subtract(1,'days').format("YYYY-MM-DD")
        }, 
            sort:date:1
    
    Meteor.publish 'events', (
        viewing_room_id
        viewing_past
        viewing_published
        )->
            
        match = {model:'event'}
        if viewing_room_id
            match.room_id = viewing_room_id
        if viewing_past
            match.date = $gt:moment().subtract(1,'days').format("YYYY-MM-DD")
            
        match.published = viewing_published    
            
        console.log moment().subtract(1,'days').format("YYYY-MM-DD")
        Docs.find match, 
            sort:date:1
    

    # Meteor.publish 'doc_by_slug', (slug)->
    #     Docs.find
    #         slug:slug
            
    # Meteor.publish 'author_by_doc_id', (doc_id)->
    #     doc_by_id =
    #         Docs.findOne doc_id
    #     doc_by_slug =
    #         Docs.findOne slug:doc_id
    #     if doc_by_id
    #         Meteor.users.findOne 
    #             _id:doc_by_id._author_id
    #     else
    #         Meteor.users.findOne 
    #             _id:doc_by_slug._author_id
            
            
    # Meteor.publish 'author_by_doc_slug', (slug)->
    #     doc = 
    #         Docs.findOne
    #             slug:slug
    #     Meteor.users.findOne 
    #         _id:doc._author_id


#     Meteor.methods
        # send_event: (event_id)->
        #     event = Docs.findOne event_id
        #     target = Meteor.users.findOne event.recipient_id
        #     gifter = Meteor.users.findOne event._author_id
        #
        #     console.log 'sending event', event
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: event.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -event.amount
        #     Docs.update event_id,
        #         $set:
        #             submitted:true
        #             submitted_timestamp:Date.now()
        #
        #
        #
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             submitted:true


 