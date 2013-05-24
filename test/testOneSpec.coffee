define ['underscore'], (_) ->
	describe 'just checking', ->
		it 'works for underscore', ->
			assert.equal(_.size([1,2,3]), 3)
