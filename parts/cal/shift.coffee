if Meteor.isClient
    Template.registerHelper 'workers', () ->
        shift = Docs.findOne Router.current().params.doc_id
        if shift.worker_ids
            Meteor.users.find   
                _id:$in:shift.worker_ids
    
    Template.registerHelper 'has_joined', () ->
        shift = Docs.findOne Router.current().params.doc_id
        if shift.worker_ids
            Meteor.userId() in shift.worker_ids
    
    Template.registerHelper 'shift_template', () ->
        Docs.findOne @shift_template_id
    Template.registerHelper 'st', () ->
        Docs.findOne @shift_template_id
    

    Router.route '/shift/:doc_id/view', (->
        @layout 'layout'
        @render 'shift_view'
        ), name:'shift_view'

    Template.shift_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
        @autorun => Meteor.subscribe 'shift_template_from_shift_id', Router.current().params.doc_id

    Template.shift_view.events
        'click .delete_item': ->
            Swal.fire({
                title: "confirm delete #{@title} shift??"
                text: "cannot be undone"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'delete'
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Router.go "/shifts"
            )

        'click .join_shift': ->
            Docs.update Router.current().params.doc_id, 
                $addToSet: 
                    worker_ids: Meteor.userId()

        'click .leave_shift': ->
            Docs.update Router.current().params.doc_id, 
                $pull: 
                    worker_ids: Meteor.userId()

if Meteor.isServer
    Meteor.publish 'shift_template_from_shift_id', (shift_id)->
        shift = Docs.findOne shift_id
        Docs.find 
            model:'shift_template'
            _id:shift.template_id
#     Meteor.methods
        # send_shift: (shift_id)->
        #     shift = Docs.findOne shift_id
        #     target = Meteor.users.findOne shift.recipient_id
        #     gifter = Meteor.users.findOne shift._author_id
        #
        #     console.log 'sending shift', shift
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: shift.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -shift.amount
        #     Docs.update shift_id,
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
    Router.route '/shift/:doc_id/edit', (->
        @layout 'layout'
        @render 'shift_edit'
        ), name:'shift_edit'

    Template.shift_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
        @autorun => Meteor.subscribe 'model_docs', 'shift_template'
    Template.shift_edit.onRendered ->


    Template.shift_edit.events
        'click .apply_template': -> Session.set('applying_template',!Session.get('applying_template'))
        
        'click .set_template': ->
            Swal.fire({
                title: "apply #{@title} template?"
                text: "this will override current values"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'apply'
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    console.log @
                    Docs.update Router.current().params.doc_id, 
                        $set:
                            title:@title
                            image_id:@image_id
                            start_time:@start_time
                            end_time:@end_time
                            start_time:@start_time
                            tags:@tags
                            description:@description
                            shift_template_id:@_id
                    $('input').transition('tada')

            )
        
        'click .select_leader': ->
            Docs.update Router.current().params.doc_id,     
                $set:leader_user_id:@_id
                
        'click .clear_leader': ->
            Docs.update Router.current().params.doc_id,     
                $unset:leader_user_id:1
                
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_shift', @_id, =>
                    Router.go "/shift/#{@_id}/view"


    Template.shift_edit.helpers
        shift_templates: ->
            Docs.find 
                model:'shift_template'
        unselected_stewards: ->
            Meteor.users.find 
                levels:$in:['steward']
    Template.shift_edit.shifts
