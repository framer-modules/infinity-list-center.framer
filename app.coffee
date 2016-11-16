# Project Info
# This info is presented in a widget when you share.
# http://framerjs.com/docs/#info.info

Framer.Info =
	title: "Center scale up list"
	author: "Jungho song"
	twitter: "threeword"
	description: "- Infinity scroll up/down\n- Recycle list item layer"
Framer.Extras.ShareInfo.enable()

#
FONT = Utils.deviceFont()
FONT_SIZE_MIN = 20
FONT_SIZE_MAX = 40

MAX_COUNT = 4
SPACE = 0

#
items = []
#
dummi = [1..12]

#
getItem = (position) -> dummi[position]
getView = (position, view, parent) ->
	view = new Layer
		width: parent.width, height: parent.height * 1/3
		backgroundColor: "transparent"
		
	view.label = new Layer
		name: ".label"
		x: Align.center, y: Align.center
		width: view.width, height: view.height
		backgroundColor: "transparent"
		style: 
			font: "500 20px/#{view.height}px #{FONT}"
			textAlign: "center"
		color: "gray"
		parent: view
	
	view.update = (position) ->
		index = position
		if position < 0 
			index = _.size(dummi) - 1 
		else if position > _.size(dummi) - 1
			index = 0
		@custom = index
		#
		@data = data = getItem index
		if data
			@label.html = "#{data}"
			
	view.update position
	
	view

#
wrap = new Layer
	x: Align.center, y: Align.center
	backgroundColor: "rgba(0,0,0,.1)"
	borderRadius: 10
	clip: true

#
center = new Layer
	y: Align.center
	width: wrap.width, height: wrap.height * 1/3
	backgroundColor: "rgba(0,0,0,.1)"
	parent: wrap
centerFrame = center.screenFrame
centerPoint = Utils.frameCenterPoint(centerFrame)

#
contents = new Layer
	x: Align.center, y: Align.center
	backgroundColor: "transparent"
	parent: wrap
contents.draggable.enabled = true
contents.draggable.horizontal = false
contents.onMove onMove = ()->
	f = _.first(items)
	l = _.last(items)
	
	# Last item move to top
	if Utils.frameInFrame(f.screenFrame, wrap.screenFrame)
		contents.removeChild l
		contents.addChild l
		
		# Update contents data
		l.update l.custom = f.custom - 1
		
		# Set y position
		l.maxY = f.y - SPACE
		# Reorder list item
		items.unshift(items.pop())
		
	# First item move to bottom
	else if !Utils.frameInFrame(items[1].screenFrame, wrap.screenFrame)
		contents.removeChild f
		contents.addChild f
		
		# Update contents data
		f.update f.custom = l.custom + 1
		
		# Set y position
		f.y = l.maxY + SPACE
		# Reorder list item
		items.push(items.shift())
	
	# Center item scale up
	for item, i in items
		distance = Utils.pointDistance(Utils.frameCenterPoint(item.screenFrame), centerPoint)
		item.label.style.fontSize = "#{Utils.modulate distance, [item.height, 0], [FONT_SIZE_MIN, FONT_SIZE_MAX], true}px"
		
# Draw list items
for i in [0...MAX_COUNT]
	# Draw
	item = getView i, null, contents
	item.name = "item - #{i+1}"
	item.y = contents.contentFrame().height
	item.y += SPACE if i isnt 1
	
	# Events
	item.ignoreEvents = false
	item.onClick -> print @data
	
	# Add item to list view
	contents.addChild item
	# Add item to array
	items.push item

#
onMove()