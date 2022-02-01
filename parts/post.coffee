if Meteor.isClient
    Router.route '/posts', (->
        @layout 'layout'
        @render 'posts'
        ), name:'posts'
    Router.route '/post/:doc_id/edit', (->
        @layout 'layout'
        @render 'post_edit'
        ), name:'post_edit'
    Router.route '/post/:doc_id', (->
        @layout 'layout'
        @render 'post_view'
        ), name:'post_view'
    Router.route '/post/:doc_id/view', (->
        @layout 'layout'
        @render 'post_view'
        ), name:'post_view_long'
    
    
    Template.posts.onCreated ->
        @autorun => @subscribe 'post_docs',
            picked_tags.array()
            Session.get('post_title_filter')

        @autorun => @subscribe 'post_facets',
            picked_tags.array()
            Session.get('post_title_filter')

    
    
    Template.posts.events
        'click .add_post': ->
            new_id = 
                Docs.insert 
                    model:'post'
            Router.go "/post/#{new_id}/edit"
            
            
            
    Template.posts.helpers
        picked_tags: -> picked_tags.array()
    
        post_docs: ->
            Docs.find {
                model:'post'
                private:$ne:true
            }, sort:_timestamp:-1    
        tag_results: ->
            Results.find {
                model:'tag'
            }, sort:_timestamp:-1

    Template.user_posts.onCreated ->
        @autorun => Meteor.subscribe 'user_posts', Router.current().params.username, ->
    Template.user_posts.helpers
        post_docs: ->
            Docs.find {
                model:'post'
            }, sort:_timestamp:-1    
    
    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.post_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id, ->


    Template.post_card.events
        'click .view_post': ->
            Router.go "/post/#{@_id}"
    Template.post_item.events
        'click .view_post': ->
            Router.go "/post/#{@_id}"

    Template.post_view.events
        'click .add_post_recipe': ->
            new_id = 
                Docs.insert 
                    model:'recipe'
                    post_ids:[@_id]
            Router.go "/recipe/#{new_id}/edit"

    # Template.favorite_icon_toggle.helpers
    #     icon_class: ->
    #         if @favorite_ids and Meteor.userId() in @favorite_ids
    #             'red'
    #         else
    #             'outline'
    # Template.favorite_icon_toggle.events
    #     'click .toggle_fav': ->
    #         if @favorite_ids and Meteor.userId() in @favorite_ids
    #             Docs.update @_id, 
    #                 $pull:favorite_ids:Meteor.userId()
    #         else
    #             $('body').toast(
    #                 showIcon: 'heart'
    #                 message: "marked favorite"
    #                 showProgress: 'bottom'
    #                 class: 'success'
    #                 # displayTime: 'auto',
    #                 position: "bottom right"
    #             )

    #             Docs.update @_id, 
    #                 $addToSet:favorite_ids:Meteor.userId()
    
    
    Template.post_edit.events
        'click .delete_post': ->
            Swal.fire({
                title: "delete post?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'post removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/posts"
            )

        'click .publish': ->
            Swal.fire({
                title: "publish post?"
                text: "point bounty will be held from your account"
                icon: 'question'
                confirmButtonText: 'publish'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'publish_post', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'post published',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

        'click .unpublish': ->
            Swal.fire({
                title: "unpublish post?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'unpublish'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'unpublish_post', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'post unpublished',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )
            
if Meteor.isServer
    Meteor.publish 'user_posts', (username)->
        user = Meteor.users.findOne username:username
        
        Docs.find 
            model:'post'
            _author_id:user._id
    
    Meteor.publish 'post_count', (
        picked_tags
        picked_sections
        post_query
        view_vegan
        view_gf
        )->
        # @unblock()
    
        # console.log picked_tags
        self = @
        match = {model:'post'}
        if picked_tags.length > 0
            match.ingredients = $all: picked_tags
            # sort = 'price_per_serving'
        if picked_sections.length > 0
            match.menu_section = $all: picked_sections
            # sort = 'price_per_serving'
        # else
            # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        if view_vegan
            match.vegan = true
        if view_gf
            match.gluten_free = true
        if post_query and post_query.length > 1
            console.log 'searching post_query', post_query
            match.title = {$regex:"#{post_query}", $options: 'i'}
        Counts.publish this, 'post_counter', Docs.find(match)
        return undefined


if Meteor.isClient
    Template.post_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.post_card.events
        'click .quickbuy': ->
            console.log @
            Session.set('quickbuying_id', @_id)
            # $('.ui.dimmable')
            #     .dimmer('show')
            # $('.special.cards .image').dimmer({
            #   on: 'hover'
            # });
            # $('.card')
            #   .dimmer('toggle')
            $('.ui.modal')
              .modal('show')

        'click .goto_food': (e,t)->
            # $(e.currentTarget).closest('.card').transition('zoom',420)
            # $('.global_container').transition('scale', 500)
            Router.go("/food/#{@_id}")
            # Meteor.setTimeout =>
            # , 100

        # 'click .view_card': ->
        #     $('.container_')

    Template.post_card.helpers
        post_card_class: ->
            # if Session.get('quickbuying_id')
            #     if Session.equals('quickbuying_id', @_id)
            #         'raised'
            #     else
            #         'active medium dimmer'
        is_quickbuying: ->
            Session.equals('quickbuying_id', @_id)

        food: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'food'
            }, sort:title:1
            

if Meteor.isServer    
    Meteor.publish 'post_facets', (
        picked_tags=[]
        title_filter
        picked_authors=[]
        picked_tasks=[]
        picked_locations=[]
        picked_timestamp_tags=[]
        )->
        # console.log 'dummy', dummy
        # console.log 'query', query
        # console.log 'picked staff', picked_authors
    
        self = @
        match = {}
        # match = {app:'pes'}
        match.model = 'post'
        # match.group_id = Meteor.user().current_group_id
        
        if title_filter and title_filter.length > 1
            match.title = {$regex:title_filter, $options:'i'}
        
        # if view_vegan
        #     match.vegan = true
        # if view_gf
        #     match.gluten_free = true
        # if view_local
        #     match.local = true
        if picked_authors.length > 0 then match._author_username = $in:picked_authors
        if picked_tags.length > 0 then match.tags = $all:picked_tags 
        if picked_locations.length > 0 then match.location_title = $in:picked_locations 
        if picked_timestamp_tags.length > 0 then match._timestamp_tags = $in:picked_timestamp_tags 
        # match.$regex:"#{product_query}", $options: 'i'}
        # if product_query and product_query.length > 1
        author_cloud = Docs.aggregate [
            { $match: match }
            { $project: "_author_username": 1 }
            { $group: _id: "$_author_username", count: $sum: 1 }
            { $match: _id: $nin: picked_authors }
            # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }
        
        author_cloud.forEach (author, i) =>
            # console.log 'queried author ', author
            # console.log 'key', key
            self.added 'results', Random.id(),
                title: author.title
                count: author.count
                model:'author'
                # category:key
                # index: i
    
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }
        
        tag_cloud.forEach (tag, i) =>
            # console.log 'queried tag ', tag
            # console.log 'key', key
            self.added 'results', Random.id(),
                title: tag.title
                count: tag.count
                model:'tag'
                # category:key
                # index: i
    
    
        location_cloud = Docs.aggregate [
            { $match: match }
            { $project: "location_title": 1 }
            # { $unwind: "$locations" }
            { $match: _id: $nin: picked_locations }
            { $group: _id: "$location_title", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }
    
        location_cloud.forEach (location, i) =>
            # console.log 'location result ', location
            self.added 'results', Random.id(),
                title: location.title
                count: location.count
                model:'location'
                # category:key
                # index: i
    
        timestamp_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "_timestamp_tags": 1 }
            { $unwind: "$_timestamp_tags" }
            { $match: _id: $nin: picked_timestamp_tags }
            { $group: _id: "$_timestamp_tags", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }
    
        timestamp_tag_cloud.forEach (timestamp_tag, i) =>
            # console.log 'timestamp_tag result ', timestamp_tag
            self.added 'results', Random.id(),
                title: timestamp_tag.title
                count: timestamp_tag.count
                model:'timestamp_tag'
                # category:key
                # index: i
    
    
    
    
        self.ready()
        
    Meteor.publish 'post_docs', (
        picked_tags
        # title_filter
        # picked_authors=[]
        # picked_tasks=[]
        # picked_locations=[]
        # picked_timestamp_tags=[]
        # product_query
        # view_vegan
        # view_gf
        # doc_limit
        # doc_sort_key
        # doc_sort_direction
        )->
    
        self = @
        match = {}
        # match = {app:'pes'}
        match.model = 'post'
        # match.group_id = Meteor.user().current_group_id
        # if title_filter and title_filter.length > 1
        #     match.title = {$regex:title_filter, $options:'i'}
        
        # if view_vegan
        #     match.vegan = true
        # if view_gf
        #     match.gluten_free = true
        # if view_local
        #     match.local = true
        # if picked_authors.length > 0 then match._author_username = $in:picked_authors
        # if picked_tags.length > 0 then match.tags = $all:picked_tags 
        # if picked_locations.length > 0 then match.location_title = $in:picked_locations 
        # if picked_timestamp_tags.length > 0 then match._timestamp_tags = $in:picked_timestamp_tags 
        console.log match
        Docs.find match, 
            limit:20
            sort:
                _timestamp:-1