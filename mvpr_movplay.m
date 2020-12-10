function mvpr_movplay(movie, varargin)

% Parse input arguments
conf = struct('debugLevel', 0,...
              'pause', 1);
conf = mvpr_getargs(conf, varargin);

playing = false;
frame = 1;

fh = figure;
playButton = uicontrol('style','pushbutton',...
		       'position', [10 10 100 40],...
		       'string', 'Play');
set(playButton, 'callback', {@play});

frameStr = sprintf('Frame %d/%d',frame, length(movie));
frameText  = uicontrol('Style','text','String',frameStr,...
           'Position',[150,10,140,15]);
posSlider = uicontrol(fh,'Style','slider',...
                'Max',length(movie),'Min',0,'Value',frame,...
                'SliderStep',[1 1],...
                'Position',[150 25 350 20]);
set(posSlider, 'callback', {@move});
imshow(movie{1});

function h = play(hObject, eventdata)
if playing == false
	set(playButton,'string', 'Pause');
	playing = true;
	while(playing == true && frame < length(movie))
		frame = frame + 1;
		
		updateView();

		pause(conf.pause);
	end
	playing = false;
	set(playButton,'string', 'Play');
	if(frame == length(movie))
		frame = 1;
		updateView();
	end
else
	set(playButton,'string', 'Play');
	playing = false;

end

end % function

function h = move(hObject, eventdata)
	playing = false;

	frame = floor(get(posSlider,'Value'));
	if frame == 0
		frame = 1;
	end

	updateView();
end % function

function updateView()

	set(posSlider, 'Value', frame);
	imshow(movie{frame});
	drawnow;
	frameStr = sprintf('Frame %d/%d',frame, length(movie));
	set(frameText, 'String', frameStr);

end % function

end % function movplay
