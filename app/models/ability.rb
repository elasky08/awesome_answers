class Ability
  include CanCan::Ability

# this ability class gets instantiated and used automatically by the CanCanCan gem. There is an assumption that you have method in the controller to get the current user and the method names is 'current_user'
# e.g. ability = Ability.new(current_user)
  def initialize(user)

    user ||= User.new

      if user.admin?
        can :manage, :all
      else
        can :read, :all
      end

    can :manage, Question do |question|
      user == question.user
    end

    can :like, Question do |question|
      user != question.user
    end
    
    # cannot :like, Question do |question|
    #   user == question.user
    # end

    can :destroy, Like do |like|
      user == like.user
    end

  end

    # this enforces that the logged in user must wither be the owner of the answer or the owner for the question that the answer references.
    # can :manage, Answer do |answer|
    #   user == answer.user || user == answer.question.user
    # end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
end
