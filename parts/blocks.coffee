if Meteor.isClient
    Template.session_toggle.events
        'click .toggle_session_var': ->
            Session.set(@key, !Session.get(@key))
            $('body').toast(
                # showIcon: 'heart'
                message: "#{@key} #{Session.get(@key)}"
                # showProgress: 'bottom'
                # class: 'success'
                displayTime: 'auto',
                position: "bottom right"
            )

    Template.session_toggle.helpers
        session_toggle_class: ->
            if Session.get(@key) then 'active' else 'basic'
   
    Template.print_this.events
        'click .print': ->
            console.log @
   
    Template.bookmark_button.helpers
        is_bookmarked: ->
            Meteor.user().bookmark_ids and @_id in Meteor.user().bookmark_ids
            
    Template.bookmark_button.events
        'click .toggle_bookmark': ->
            if Meteor.user().bookmark_ids and @_id in Meteor.user().bookmark_ids
                Meteor.users.update Meteor.userId(), 
                    $pull: 
                        bookmark_ids:@_id
                $('body').toast(
                    showIcon: 'bookmark'
                    message: 'bookmark removed'
                    # showProgress: 'bottom'
                    class: 'info'
                    displayTime: 'auto',
                    position: "bottom right"
                )
                        
            else 
                Meteor.users.update Meteor.userId(), 
                    $addToSet: 
                        bookmark_ids:@_id
                $('body').toast(
                    showIcon: 'bookmark'
                    message: 'bookmark added'
                    # showProgress: 'bottom'
                    class: 'success'
                    displayTime: 'auto',
                    position: "bottom right"
                )
                
   
    Template.comments.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.comments.onCreated ->
        if Router.current().params.doc_id
            parent = Docs.findOne Router.current().params.doc_id
        # else
        #     parent = Docs.findOne Template.parentData()._id
        if parent
            @autorun => Meteor.subscribe 'children', 'comment', parent._id
    Template.comments.helpers
        doc_comments: ->
            if Router.current().params.doc_id
                parent = Docs.findOne Router.current().params.doc_id
            else
                parent = Docs.findOne Template.parentData()._id
            if parent
                Docs.find
                    parent_id:parent._id
                    model:'comment'
    Template.comments.events
        'keyup .add_comment': (e,t)->
            if e.which is 13
                if Router.current().params.doc_id
                    parent = Docs.findOne Router.current().params.doc_id
                else
                    parent = Docs.findOne Template.parentData()._id
                # parent = Docs.findOne Router.current().params.doc_id
                comment = t.$('.add_comment').val()
                Docs.insert
                    parent_id: parent._id
                    model:'comment'
                    parent_model:parent.model
                    body:comment
                t.$('.add_comment').val('')

        'click .remove_comment': ->
            if confirm 'Confirm remove comment'
                Docs.remove @_id

    Template.follow.helpers
        followers: ->
            Meteor.users.find
                _id: $in: @follower_ids
        following: -> @follower_ids and Meteor.userId() in @follower_ids
    Template.follow.events
        'click .follow': ->
            Docs.update @_id,
                $addToSet:follower_ids:Meteor.userId()
        'click .unfollow': ->
            Docs.update @_id,
                $pull:follower_ids:Meteor.userId()

    Template.set_limit.events
        'click .set_limit': ->
            console.log @
            Session.set('limit', @amount)

    Template.set_sort_key.helpers
        sort_button_class: ->
            if Session.equals('sort_key', @key) then 'blue' else 'basic compact'
    Template.set_sort_key.events
        'click .set_sort': ->
            console.log @
            Session.set('sort_key', @key)
            Session.set('post_sort_label', @label)
            Session.set('post_sort_icon', @icon)




    Template.voting.events
        'click .upvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @
        'click .downvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @


    Template.voting_small.events
        'click .upvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @
        'click .downvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @



    # Template.doc_card.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Template.currentData().doc_id
    # Template.doc_card.helpers
    #     doc: ->
    #         Docs.findOne
    #             _id:Template.currentData().doc_id





    # Template.call_watson.events
    #     'click .autotag': ->
    #         doc = Docs.findOne Router.current().params.doc_id
    #         console.log doc
    #         console.log @
    #
    #         Meteor.call 'call_watson', doc._id, @key, @mode

    Template.voting_full.events
        'click .upvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @
        'click .downvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @




    Template.role_editor.onCreated ->
        @autorun => Meteor.subscribe 'model', 'role'



    # Template.user_card.onCreated ->
    #     @autorun => Meteor.subscribe 'user_from_username', @data
    # Template.user_card.helpers
    #     user: -> Meteor.users.findOne @valueOf()




    # Template.big_user_card.onCreated ->
    #     @autorun => Meteor.subscribe 'user_from_username', @data
    # Template.big_user_card.helpers
    #     user: -> Meteor.users.findOne username:@valueOf()




    # Template.username_info.onCreated ->
    #     @autorun => Meteor.subscribe 'user_from_username', @data
    # Template.username_info.events
    #     'click .goto_profile': ->
    #         user = Meteor.users.findOne username:@valueOf()
    #         if user.is_current_member
    #             Router.go "/member/#{user.username}/"
    #         else
    #             Router.go "/user/#{user.username}/"
    # Template.username_info.helpers
    #     user: -> Meteor.users.findOne username:@valueOf()




    # Template.user_info.onCreated ->
    #     @autorun => Meteor.subscribe 'user_from_id', @data
    # Template.user_info.helpers
    #     user: -> Meteor.users.findOne @valueOf()


    Template.toggle_edit.events
        'click .toggle_edit': ->
            console.log @
            console.log Template.currentData()
            console.log Template.parentData()
            console.log Template.parentData(1)
            console.log Template.parentData(2)
            console.log Template.parentData(3)
            console.log Template.parentData(4)




    # Template.user_list_info.onCreated ->
    #     @autorun => Meteor.subscribe 'user', @data

    # Template.user_list_info.helpers
    #     user: ->
    #         console.log @
    #         Meteor.users.findOne @valueOf()



    # Template.user_field.helpers
    #     key_value: ->
    #         user = Meteor.users.findOne Router.current().params.doc_id
    #         user["#{@key}"]

    # Template.user_field.events
    #     'blur .user_field': (e,t)->
    #         value = t.$('.user_field').val()
    #         Meteor.users.update Router.current().params.doc_id,
    #             $set:"#{@key}":value


    Template.goto_model.events
        'click .goto_model': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', @slug, ->
                Session.set 'loading', false





    Template.viewing.events
        'click .mark_read': (e,t)->
            Docs.update @_id,
                $inc:views:1
            unless @read_ids and Meteor.userId() in @read_ids
                Meteor.call 'mark_read', @_id, ->
                    # $(e.currentTarget).closest('.comment').transition('pulse')
                    $('.unread_icon').transition('pulse')
        'click .mark_unread': (e,t)->
            Docs.update @_id,
                $inc:views:-1
            Meteor.call 'mark_unread', @_id, ->
                # $(e.currentTarget).closest('.comment').transition('pulse')
                $('.unread_icon').transition('pulse')
    Template.viewing.helpers
        viewed_by: -> Meteor.userId() in @read_ids
        readers: ->
            readers = []
            if @read_ids
                for reader_id in @read_ids
                    unless reader_id is @author_id
                        readers.push Meteor.users.findOne reader_id
            readers




    Template.add_button.onCreated ->
        # console.log @
        Meteor.subscribe 'model_from_slug', @data.model
    Template.add_button.helpers
        model: ->
            data = Template.currentData()
            Docs.findOne
                model: 'model'
                slug: data.model
    Template.add_button.events
        'click .add': ->
            new_id = Docs.insert
                model: @model
            Router.go "/m/#{@model}/#{new_id}/edit"


    Template.remove_button.events
        'click .remove_doc': (e,t)->
            if confirm "remove #{@model}?"
                if $(e.currentTarget).closest('.card')
                    $(e.currentTarget).closest('.card').transition('fly right', 1000)
                else
                    $(e.currentTarget).closest('.segment').transition('fly right', 1000)
                    $(e.currentTarget).closest('.item').transition('fly right', 1000)
                    $(e.currentTarget).closest('.content').transition('fly right', 1000)
                    $(e.currentTarget).closest('tr').transition('fly right', 1000)
                    $(e.currentTarget).closest('.event').transition('fly right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 1000

    Template.remove_icon.events
        'click .remove_doc': (e,t)->
            if confirm "remove #{@model}?"
                if $(e.currentTarget).closest('.card')
                    $(e.currentTarget).closest('.card').transition('fly right', 1000)
                else
                    $(e.currentTarget).closest('.segment').transition('fly right', 1000)
                    $(e.currentTarget).closest('.item').transition('fly right', 1000)
                    $(e.currentTarget).closest('.content').transition('fly right', 1000)
                    $(e.currentTarget).closest('tr').transition('fly right', 1000)
                    $(e.currentTarget).closest('.event').transition('fly right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 1000

    Template.session_set.events
        'click .set_session_value': ->
            # console.log @key
            # console.log @value
            if Session.equals(@key, @value)
                Session.set(@key,null)
            else
                Session.set(@key, @value)

    Template.session_set.helpers
        calculated_class: ->
            res = ''
            # console.log @
            if @cl
                res += @cl
            if Session.equals(@key,@value)
                res += ' blue'
            else 
                res += ' '
            # console.log res
            res

    



    Template.key_value_edit.events
        'click .set_key_value': ->
            # console.log @key
            # console.log @value
            # Docs.update Router.current().params.doc_id,
            context = Template.parentData()
            if context
                Docs.update context._id, 
                    $set:
                        "#{@key}":@value
            # Session.set(@key, @value)

    Template.key_value_edit.helpers
        calculated_class: ->
            res = ''
            # doc = Docs.findOne Router.current().params.doc_id
            doc = Template.parentData()
            
            # console.log @
            if @cl
                res += @cl
            # if Session.equals(@key,@value)
            if doc["#{@key}"]  is @value
                res += ' black'
            else 
                res += ' basic'
            # console.log res
            res



    

    Template.session_boolean_toggle.events
        'click .toggle_session_key': ->
            console.log @key
            Session.set(@key, !Session.get(@key))

    Template.session_boolean_toggle.helpers
        calculated_class: ->
            res = ''
            # console.log @
            if @cl
                res += @cl
            if Session.get(@key)
                res += ' blue'
            else
                res += ' basic'

            # console.log res
            res

if Meteor.isServer
    Meteor.methods
        'send_kiosk_message': (message)->
            parent = Docs.findOne message.parent._id
            Docs.update message._id,
                $set:
                    sent: true
                    sent_timestamp: Date.now()
            Docs.insert
                model:'log_event'
                log_type:'kiosk_message_sent'
                text:"kiosk message sent"


    Meteor.publish 'children', (model, parent_id, limit)->
        # console.log model
        # console.log parent_id
        limit = if limit then limit else 10
        Docs.find {
            model:model
            parent_id:parent_id
        }, limit:limit
        
        
if Meteor.isClient
    Template.doc_array_togggle.helpers
        doc_array_toggle_class: ->
            parent = Template.parentData()
            # user = Meteor.users.findOne Router.current().params.username
            if parent["#{@key}"] and @value in parent["#{@key}"] then 'active' else 'basic'
    Template.doc_array_togggle.events
        'click .toggle': (e,t)->
            parent = Template.parentData()
            if parent["#{@key}"]
                if @value in parent["#{@key}"]
                    Docs.update parent._id,
                        $pull: "#{@key}":@value
                else
                    Docs.update parent._id,
                        $addToSet: "#{@key}":@value
            else
                Docs.update parent._id,
                    $addToSet: "#{@key}":@value


    # Template.friend_finder.onCreated ->
    #     @user_results = new ReactiveVar
    # Template.friend_finder.helpers
    #     user_results: ->Template.instance().user_results.get()
    # Template.friend_finder.events
    #     'click .clear_results': (e,t)->
    #         t.user_results.set null
    
    #     'keyup .find_friend': (e,t)->
    #         search_value = $(e.currentTarget).closest('.find_friend').val().trim()
    #         if search_value.length > 1
    #             console.log 'searching', search_value
    #             Meteor.call 'lookup_user', search_value, @role_filter, (err,res)=>
    #                 if err then console.error err
    #                 else
    #                     t.user_results.set res
    
    #     'click .select_user': (e,t) ->
    #         page_doc = Docs.findOne Router.current().params.doc_id
    #         field = Template.currentData()
    
    #         # console.log @
    #         # console.log Template.currentData()
    #         # console.log Template.parentData()
    #         # console.log Template.parentData(1)
    #         # console.log Template.parentData(2)
    #         # console.log Template.parentData(3)
    #         # console.log Template.parentData(4)
    
    
    #         val = t.$('.edit_text').val()
    #         if field.direct
    #             parent = Template.parentData()
    #         else
    #             parent = Template.parentData(5)
    
    #         doc = Docs.findOne parent._id
    #         if doc
    #             Docs.update parent._id,
    #                 $set:"#{field.key}":@_id
    #         else
    #             Meteor.users.update parent._id,
    #                 $set:"#{field.key}":@_id
                
    #         t.user_results.set null
    #         $('.find_friend').val ''
    #         # Docs.update page_doc._id,
    #         #     $set: assignment_timestamp:Date.now()
    
    #     'click .pull_user': ->
    #         if confirm "remove #{@username}?"
    #             parent = Template.parentData(1)
    #             field = Template.currentData()
    #             doc = Docs.findOne parent._id
    #             if doc
    #                 Docs.update parent._id,
    #                     $unset:"#{field.key}":1
    #             else
    #                 Meteor.users.update parent._id,
    #                     $unset:"#{field.key}":1
    
    #         #     page_doc = Docs.findOne Router.current().params.doc_id
    #             # Meteor.call 'unassign_user', page_doc._id, @
    
    
    
if Meteor.isClient
    Template.model_picker.onCreated ->
        @autorun => @subscribe 'model_search_results', Session.get('model_search'), ->
        @autorun => @subscribe 'model_docs', @data.model, ->
    Template.model_picker.helpers
        model_results: ->
            Docs.find 
                model:Template.currentData().model
                # title: {$regex:"#{Session.get('model_search')}",$options:'i'}
                
        picked_model: ->
            parent_doc = Docs.findOne Router.current().params.doc_id
            # _id:parent_doc["#{Template.currentData().model}_id"]
            # console.log Template.currentData().model
            Docs.findOne
                # model:Template.currentData().model
                _id:parent_doc["#{Template.currentData().model}_id"]
        model_search_value: ->
            Session.get('model_search')
        
    Template.model_picker.events
        'click .clear_search': (e,t)->
            Session.set('model_search', null)
            t.$('.model_search').val('')

            
        'click .remove_model': (e,t)->
            if confirm "remove #{@title} model?"
                Docs.update Router.current().params.doc_id,
                    $unset:
                        "#{Template.currentData().model}_id":@_id
                        "#{Template.currentData().model}_title":@title
        'click .pick_model': (e,t)->
            Docs.update Router.current().params.doc_id,
                $set:
                    "#{Template.currentData().model}_id":@_id
                    "#{Template.currentData().model}_title":@title
            Session.set('model_search',null)
            t.$('.model_search').val('')
                    
        'keyup .model_search': (e,t)->
            # if e.which is '13'
            val = t.$('.model_search').val()
            console.log val
            Session.set('model_search', val)

        'click .create_model': ->
            new_id = 
                Docs.insert 
                    model:'model'
                    title:Session.get('model_search')
            Router.go "/model/#{new_id}/edit"


if Meteor.isServer 
    Meteor.publish 'model_search_results', (model_title_queary)->
        Docs.find 
            model:'model'
            title: {$regex:"#{model_title_queary}",$options:'i'}
        
        

if Meteor.isClient
    Template.search_input.events
        'keyup .search_input': _.throttle((e,t)->
            search_value = $(e.currentTarget).closest('.search_input').val().trim()
            # if search_value.length > 1
            console.log 'searching', search_value
            Session.set('search_value', search_value)
            if e.which is 27
        	    if Session.get('search_value')
                    $('body').toast(
                        showIcon: 'cancel'
                        message: 'search cleared'
                        # showProgress: 'bottom'
                        class: 'success'
                        displayTime: 'auto'
                        position: 'top right'
                    )
        	        Session.set('search_value', null)
        , 400)       
        	  
        'click .clear_query': (e,t)->
    	    if Session.get('search_value')
                $('body').toast(
                    showIcon: 'cancel'
                    message: 'search cleared'
                    # showProgress: 'bottom'
                    class: 'success'
                    displayTime: 'auto'
                    position: 'top right'
                )
                $(e.currentTarget).closest('.input').transition('jiggle', 500)
                
                
    	        Session.set('search_value', null)
            


    Template.search_input.helpers
        current_query: -> Session.get('search_value')
        search_input_class: ->
            if Session.get('search_value') then 'large active circular' else 'small'

    Template.add_model_button.events        
        'click .add_model_doc': ->
            new_id = 
                Docs.insert 
                    model:@model
                    published:false
                    # purchased:false
            Router.go "/#{@model}/#{new_id}/edit"
