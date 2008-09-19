function plotData(X,Y,data,bounds,varargin)

if check_option(varargin,'colorrange','double')
  cr = get_option(varargin,'colorrange',[],'double');
  if cr(2)-cr(1) < 1e-15
    caxis([min(cr(1),0),max(cr(2),1)]);
  else
    caxis(cr);
  end
end

plottype = get_flag(varargin,{'CONTOUR','CONTOURF','dots','smooth','scatter'});

% contour plot
if any(strcmpi(plottype,{'CONTOUR','CONTOURF'})) 

  set(gcf,'Renderer','painters');
  contours = get_option(varargin,{'contourf','contour'},{},'double');
  if ~isempty(contours), contours = {contours};end
  
  if check_option(varargin,'CONTOURF') % filled contour plot
  
    [CM,h] = contourf(X,Y,data,contours{:});
    set(h,'LineStyle','none');
  end
  
  contour(X,Y,data,contours{:},'k');
       
% smooth plot
elseif any(strcmpi(plottype,'SMOOTH'))
  
  if check_option(varargin,'interp')   % interpolated

    pcolor(X,Y,data);
    if numel(data) >= 500
     if length(unique(data))<50
       shading flat;
     else
       shading interp;
       set(gcf,'Renderer','zBuffer');
     end
    else
      set(gcf,'Renderer','painters');
    end
        
  else  
    
    set(gcf,'Renderer','painters');
    if isappr(min(data(:)),max(data(:))) % empty plot
      ind = convhull(X,Y);
      fill(X(ind),Y(ind),min(data(:)));
    else
      [CM,h] = contourf(X,Y,data,50);
      set(h,'LineStyle','none');
    end

  end
  
% scatter plots
else 
    
  color = get_option(varargin,'MarkerColor','b');
  
  if isa(data,'cell') || (isempty(data) && numel(X)<50) % unscaled scatter plot
    
    % restrict to plotted region
    if check_option(varargin,'annotate')
      x = get(gca,'xlim');
      y = get(gca,'ylim');
      ind = find(X >= x(1)-0.0001 & X <= x(2)+0.0001 & Y >= y(1)-0.0001 & Y <= y(2)+0.0001);
    else
      ind = 1:numel(X);
    end
   
    % plot labels
    for i = 1:length(ind)
      j = ind(i);
      if isa(data,'cell') && ~check_option(varargin,'notext')
        smarttext(X(j),Y(j),data{j},bounds,...
          'Interpreter','latex','Margin',0.1,varargin{:});
      end
    end
    
    % plot markers
    optiondraw(scatter(X(ind),Y(ind),[],color,'filled'),varargin{:});
    
  else % scaled scatter plot
    
    set(gcf,'Renderer','Painters');

    res = get_option(varargin,'scatter_resolution',5*degree);
    storeSize = get_option(varargin,'MarkerSize',50*res)/50;
    markerSize = get_option(varargin,'MarkerSize',min(10,max(1,50*res)));
    
    if ~isempty(data) && isa(data,'double')
      % data colored markers
      
      range = get_option(varargin,'colorrange',...
        [min(data(data>-inf)),max(data(data<inf))],'double');
    
      in_range = data >= range(1) & data <= range(2);
    
      % draw out of range markers
      patch(X(~in_range),Y(~in_range),1,...
        'FaceColor','none',...
        'EdgeColor','none',...
        'MarkerFaceColor','w',...
        'MarkerEdgeColor','k',...
        'MarkerSize',markerSize,...
        'Marker','o',...
        'tag','scatterplot','UserData',storeSize);

      % draw ordinary markers
      patch(X(in_range),Y(in_range),data(in_range),...
      'FaceColor','none',...
      'EdgeColor','none',...
      'MarkerFaceColor','flat',...
      'MarkerEdgeColor','flat',...
      'MarkerSize',markerSize,...
      'Marker','o',...
      'tag','scatterplot','UserData',storeSize);
      
    else % single colored markers
      
      patch(X,Y,1,...
        'FaceColor','none',...
        'EdgeColor','none',...
        'MarkerFaceColor',color,...
        'MarkerEdgeColor',color,...
        'MarkerSize',markerSize,...
        'Marker','o',...
        'tag','scatterplot','UserData',storeSize);
    end
  end  
end
