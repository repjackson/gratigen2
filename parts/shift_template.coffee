if Meteor.isClient
    Template.registerHelper 'default_shift_template_leader', () ->
        Meteor.users.findOne @default_leader_user_id
    
    Router.route '/shift_templates/', (->
        @layout 'layout'
        @render 'shift_templates'
        ), name:'shift_templates'
    Router.route '/shift_template/:doc_id/view', (->
        @layout 'layout'
        @render 'shift_template_view'
        ), name:'shift_template_view'

    Template.shift_template_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'

    Template.shift_templates.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'shift_template'
    Template.shift_templates.events
        'click .add_shift_template': ->
            new_id = 
                Docs.insert
                    model:'shift_template'
            Router.go "/shift_template/#{new_id}/edit"
    Template.shift_templates.helpers
        next_shift_templates: ->
            Docs.find {model:'shift_template'}, 
                sort:
                    start_datetime:-1



    Template.shift_template_view.onRendered ->
        @autorun => Meteor.subscribe 'users'
    Template.shift_template_view.helpers
        
        
    Template.shift_template_view.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .create_instance': ->
            new_shift_id = 
                Docs.insert
                    model:'shift'
                    template_id:Router.current().params.doc_id
            Router.go "/shift/#{new_shift_id}/edit"

# if Meteor.isServer
#     Meteor.methods
        # send_shift_template: (shift_template_id)->
        #     shift_template = Docs.findOne shift_template_id
        #     target = Meteor.users.findOne shift_template.recipient_id
        #     gifter = Meteor.users.findOne shift_template._author_id
        #
        #     console.log 'sending shift_template', shift_template
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: shift_template.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -shift_template.amount
        #     Docs.update shift_template_id,
        #         $set:
        #             submitted:true
        #             submitted_timestamp:Date.now()
        #
        #
        #
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             submitted:true


if Meteor.isClient
    Router.route '/shift_template/:doc_id/edit', (->
        @layout 'layout'
        @render 'shift_template_edit'
        ), name:'shift_template_edit'

    Template.shift_template_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
    Template.shift_template_edit.onRendered ->


    Template.shift_template_edit.events
        'click .select_default_leader': ->
            Docs.update Router.current().params.doc_id,     
                $set:default_leader_user_id:@_id
                
        'click .clear_default_leader': ->
            Docs.update Router.current().params.doc_id,     
                $unset:default_leader_user_id:1
                
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_shift_template', @_id, =>
                    Router.go "/shift_template/#{@_id}/view"


    Template.shift_template_edit.helpers
        unselected_stewards: ->
            Meteor.users.find 
                levels:$in:['steward']
    Template.shift_template_edit.shift_templates
