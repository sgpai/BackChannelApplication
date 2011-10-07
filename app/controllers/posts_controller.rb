class PostsController < ApplicationController
  before_filter :authorize, :except => :search

  # GET /posts
  # GET /posts.json
  def index

    @year = Time.now.year
    @month = Time.now.month
    @day = Time.now.day

    if(@day < 10)
      @day = "0" + @day.to_s()
    end
    @date = ("#{@year}-#{@month}-#{@day}")
    p "date #{@date}"

    @todaysPosts = Post.find(:all, :conditions => ["created_at like ? and parentPostID = id", "#{@date}%"], :order => ["created_at desc"] )

    #show posts ordered by weight
    @postsByWeight = Post.order("weight DESC")

    #check toggle Flag
    @toggleFlag = params[:toggleF]

    #if toggle Flag is nil or flag, it means the user has selected a view to display only parent posts
    if(@toggleFlag.nil? || @toggleFlag.to_s() == "false")

    @parentPosts = Array.new
    @postsByWeight.each do |post|
       if(post.id == post.parentPostID)
           matchFlag = "false"
           @todaysPosts.each do |todaysPost|
               if(post.id == todaysPost.id)
                   matchFlag = "true"
               end
           end
           if(matchFlag == "false")
               @parentPosts << post
           end
       end
    end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @parentPosts }
      end

    #if toggle Flag is true, it means the user has selected a view to display parent posts
    #and their corresponding replies in a cascaded fashion  Post.find(:all, :conditions => ["id = parentPostID"],:order => "weight DESC")
    elsif(@toggleFlag.to_s() == "true")
      @parentPostsForToggle = Array.new
      @postsByWeight.each do |post|
        if(post.id == post.parentPostID)
          matchFlag = "false"
           @todaysPosts.each do |todaysPost|
               if(post.id == todaysPost.id)
                   matchFlag = "true"
               end
           end
           if(matchFlag == "false")
               @parentPostsForToggle << post
           end
        end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @parentPostsForToggle }
    end
    end
  end

  #GET /posts/toggle
  #toggle function is called everytime the toggle link is pressed.
  #It toggles the posts view from displaying only parent posts to displaying both parent and their replies.
  def toggle
    #toggle the flag value
    if((@toggleFlag.nil?) || (@toggleFlag.to_s() == "false"))
      @toggleFlag = "true"
    elsif(@toggleFlag.to_s() == "true")
      @toggleFlag = "false"
    end

    #redirect to the posts index page with the altered toggle flag
    redirect_to posts_path(:toggleF => @toggleFlag)
  end

  #POST posts/vote
  #vote for a particular post
  def vote
    @post = Post.find(params[:id])

    respond_to do |format|
        #Create a vote object with the necessary parameters
        @foundVote = Vote.new
        @foundVote.post_id = params[:id]
        @foundVote.user_id = User.find_by_userName(session[:userName]).id
        @foundVote.numberOfVotes = 0

        #save the vote and redirection to the parent post page for display
        if @foundVote.save()
          metric(@foundVote.post_id)
          increaseTotalVotes(params[:id])
          format.html { redirect_to Post.find(Post.find(params[:id]).parentPostID), notice: 'Vote successfully submitted.' }
          format.json { render json: @post, status: :created, location: @post }
        else
          format.html { render action: "new" }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
  end

  def increaseTotalVotes(postID)
    @parentPost = Post.find(Post.find(postID).parentPostID)

    @parentPost.update_attribute("totalVotes", @parentPost.totalVotes + 1)
  end

  # create the reply for the parent post
  # POST /posts/createreply
  def createreply
    #create the reply object
    @user = User.find_by_userName(session[:userName])
    @post = Post.new(:user_id => @user.id, :postString => params[:replyContent], :parentPostID => params[:parentPostID], :totalVotes => 0)

    respond_to do |format|
      #save the reply and redirect to the parent post page for display
      if @post.save
          format.html { redirect_to Post.find(params[:parentPostID]), notice: 'Reply to this post is saved. See the \'All replies\' section.' }
          format.json { render json: Post.find(params[:parentPostID]), status: :created, location: Post.find(params[:parentPostID]) }
      else
          format.html { render action: "new" }
          format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /posts/reply
  # retrieving the parent post ID to move to the reply page to post the reply
  def reply
    @post = Post.find_by_id(params[:id])
  end

  # GET /posts/search
  # search function receives search keyword or userName in params[:searchQuery]
  # searchByContent is done by simple pattern matching
  def search
    #if search by content
    if((!params[:searchQuery].nil?) && (params[:selectSearch].to_s == "searchContent"))
      @posts = Post.find(:all, :conditions => ["postString like ? and id == parentPostID", "%#{params[:searchQuery]}%"])

      #if search by user
    elsif((!params[:searchQuery].nil?) && (params[:selectSearch].to_s == "searchUser"))
      @user = User.find_by_userName(params[:searchQuery])
      if(@user.nil?)
      else
        @posts = Post.find(:all, :conditions => ["user_id = ? and id == parentPostID", @user.id])
      end
    end

    respond_to do |format|
        format.html
        format.json { render json: @posts }
      end
  end

  # GET /posts/1
  # GET /posts/1.json
  # show the parent post and its corresponding replies
  def show
    @parentPost = Post.find(params[:id])
    @childPosts = Post.find(:all, :conditions => ["parentPostID = ? and parentPostID <> id", params[:id]])
  end

  # GET /posts/showpostactivity
  # show the post activity grouped by parent posts, votes and users
  def showpostactivity
    if(session[:loginType] == 'admin')
      @user = User.find(:all, :conditions => ["userName = ?", session[:userName]])
      @parentPosts = Post.find(:all, :conditions => ["id == parentPostID"])
      @userByPosts = Post.select("user_id as userID, count(id) as numberOfPosts").group("user_id").order("numberOfPosts")
      @userByVotes = Vote.select("user_id as userID, count(post_id) as numberOfVotes").group("user_id").order("numberOfVotes")

    else
      flash[:notice] = 'Access denied'
      redirect_to users_notauthorized_path
    end
  end

  # GET /posts/new
  # GET /posts/new.json
  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(params[:post])
    @user = User.find_by_userName(session[:userName])

    respond_to do |format|
      if @post.save
        @post.parentPostID = @post.id

        #update the parent post id
        @post.update_attribute("parentPostID",@post.parentPostID)
        @post.update_attribute("weight",30)
        @post.update_attribute("totalVotes", 0)

        metric(@post.id)

        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render json: @post, status: :created, location: @post }
      else
        format.html { render action: "new" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    #find the parent post
    @post = Post.find(params[:id])

    parentVotes = Vote.find(:all, :conditions => ["post_id = ?", @post.id])

    #remove the votes for the parent post
    parentVotes.each do |parentVote|
      parentVote.destroy
    end

    #find all child posts
    @childPosts = Post.find(:all, :conditions => ["parentPostID = ? and id <> parentPostID", params[:id]])

    #remove the votes of all child posts
    @childPosts.each do |childPost|
      votes = Vote.find(:all, :conditions => ["post_id = ?", childPost.id])
      votes.each do |vote|
        vote.destroy
      end
    end

    #remove the child posts
    @childPosts.each do |childPost|
      childPost.destroy
    end

    #finally, remove the parent post
    @post.destroy

    respond_to do |format|
      if(@post.id == @post.parentPostID)
        format.html { redirect_to posts_url, notice: "The post is successfully removed"}
      else
        format.html { redirect_to Post.find(Post.find(@post.parentPostID)), notice: "The post is successfully removed"}
      end
      format.json { head :ok }
    end
  end

  def metric(postID)
    posted = Date.new
    postArray = Post.find(postID)

    posted = postArray.created_at.to_date
    diff = (Date.today-posted).to_i

    nVotes = Vote.find_all_by_post_id(postID).length
    weight = 30 - (diff * 5) + nVotes

    upPost = Post.find(postID)
    upPost.update_attribute("weight",weight)
  end
end