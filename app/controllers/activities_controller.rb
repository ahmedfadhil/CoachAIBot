require 'csv_data/user_export'

class ActivitiesController < ApplicationController
  layout 'profile'
  
  def show
    @activity = Activity.find(params[:id])
  
    
  end
  
  def index
    @activities = Activity.all
  end
  
  def new
    @activity = Activity.new
  end
  
  def create
    activity = Activity.new activity_params
    if activity.save
      flash[:OK] = 'La tua attivita\' e\' stata AGGIUNTA con successo!'
    else
      flash[:err] = "L'Attivita NON E' STATA INSERITA"
      flash[:errors] = activity.errors.messages
    end
    redirect_to activities_path
  end
  
  def edit
  end
  
  def update
    activity = Activity.find(params[:id])
    if !activity.update(activity_params)
      flash[:OK] = "L'Attivita e' stata modificata con successo!"
    else
      flash[:err] = "C'e' stato un problema durante l'aggiornamento dell'attivita'. La preghiamo di ricontrollare i dati inseriti e riprovare."
      flash[:errors] = activity.errors.messages
    end
    redirect_to activities_path
  end
  
  def destroy
    activity = Activity.find(params[:id])
    if activity.destroy
      flash[:OK] = 'La tua attivita\' e\' stata eliminata con successo!'
    else
      flash[:err] = "C'e' stato un problema durante la distruzione dell'attivita'. La preghiamo di riprovare piu' tardi."
      flash[:errors] = activity.errors.messages
    end
    redirect_to activities_path
  end
  
  def diets
    @activities = Activity.where(:category => 0)
  end
  
  def physicals
    @activities = Activity.where(:category => 1)
  end
  
  def mentals
    @activities = Activity.where(:category => 2)
  end
  
  def medicinals
    @activities = Activity.where(:category => 3)
  end
  
  def others
    @activities = Activity.where(:category => 4)
  end
  
  
  # Download data into csv
  def saveAllData
    csv = UserExport.allData.to_csv.string
    send_data(csv,
              filename: 'allData.csv',
              type: 'text/csv',
              disposition: 'attachment')
  end

  def saveUserData
    user= User.find(params[:id])
    csv = UserExport.userData(user).to_csv.string
    send_data(csv,
              filename: 'userData.csv',
              type: 'text/csv',
              disposition: 'attachment')
  end
  
  
  private
  
  def activity_params
    params.require(:activity).permit(:name, :desc, :a_type, :category, :n_times)
  end

end
