Pulsar::Application.routes.draw do

  resources :primers do 
    get :select_options, on: :collection
    get :mate_primer_selection, on: :collection
  end

  resources :gel_images

  resources :atacseqs do
    get :select_biosample_libraries, on: :member
    get :single_cell, on: :collection
    get :snrna, on: :collection
    get :multiome, on: :collection
    get :bulk, on: :collection
    get :select_experimental_biosample, on: :member
  end
  resources :batch_items do 
    post :create_library_from_prototype, on: :member
  end
  resources :batches do
    get :bulk_atacseq_index, on: :collection
    get :sc_atacseq_index, on: :collection
    get :sn_rnaseq_index, on: :collection
    get :multiome_atacseq_index, on: :collection
    get :chipseq_index, on: :collection
    get :refresh_batch_item_row, on: :member 
    get :add_batch_item, on: :member
    post :create_or_update_batch_item, on: :member
    delete :remove_batch_item, on: :member
  end
  resources :shippings
  resources :immunoblots do
    get :add_gel, on: :member
    get :select_gel, on: :member
  end
  resources :gels do
    get :add_gel_image, on: :member
    get :add_lane, on: :member
    post :create_or_update_gel_lane, on: :member
    delete :remove_gel_lane, on: :member
  end
  resources :gel_lanes
  resources :chipseq_experiments do
    get :select_biosample_libraries, on: :member
    get :select_control_biosample, on: :member
    get :get_wt_control_selection, on: :collection
    get :select_experimental_biosample, on: :member
  end
  get 'search/search'

  resources :treatments do
    get :select_options, on: :collection
  end

  resources :treatment_term_names do
    get :select_options, on: :collection
  end

  resources :pcrs do
    get :add_gel, on: :member
    get :select_gel, on: :member
  end

  resources :pcr_master_mixes do
    get :select_options, on: :collection
  end
  resources :analyses do
    get :add_merged_file, on: :member
    get :add_merged_file, on: :collection
  end
  resources :data_file_types do
    get :select_options, on: :collection
  end
  resources :file_references
  resources :data_storage_providers
  resources :data_storages do
    get :select_options, on: :collection
    get :get_base_path, on: :member
    get :customize_for_data_storage_provider, on: :collection
  end
  resources :units do
    get :select_options, on: :collection
  end
  resources :single_cell_sortings do
    get :add_plate, on: :member
    get :add_sorting_biosample, on: :member
    get :add_library_prototype, on: :member
    get :new_analysis, on: :member
  end
  resources :addresses
  resources :plates do
    get :show_barcodes, on: :member
    resources :wells, except: [:index, :new, :destroy]
  end
  resources :paired_barcodes
  resources :crispr_modifications do
    get :prototype_instances, on: :member
    get :select_options, on: :collection
    #crisprs only belong to biosamples.
    get :select_crispr_construct, on: :collection
    #select_crispr_construct on collection instead of member b/c the user selects this when creating or editing the crispr object, and
    # since the crispr won't have an id yet when being created, we can't use :member.
    get :select_chromosome_on_reference_genome, on: :collection
  end
  resources :crispr_constructs do
    get :select_options, on: :collection
    get :select_construct_tag, on: :collection
  end

  resources :donor_constructs do
    get :select_construct_tag, on: :collection
  end

  resources :construct_tags

  resources :cloning_vectors do
    get :select_options, on: :collection
  end

  resources :genome_locations
  resources :sequencing_library_prep_kits do
    get :select_options, on: :collection
    get :dual_indexing_kits, on: :collection
    resources :barcodes, except: [:index]
  end
  resources :library_fragmentation_methods
  resources :biosample_term_names do
    get :select_options, on: :collection
  end

  resources :sequencing_centers do
    get :select_options, on: :collection
  end

  namespace :api do
    resources "utils" do
      get "model_attrs", on: :collection
    end

    resources :atacseqs do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :barcodes do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :batches do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :batch_items do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :biosamples do
      get :parent_ids, on: :member
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :biosample_ontologies do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :biosample_replicates do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :biosample_types do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :biosample_term_names do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :crispr_modifications do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :data_storages do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :data_storage_providers do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :chipseq_experiments do
      get :paired_input_control_map, on: :member
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :file_references do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :units do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end
    resources :construct_tags do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end
    resources :crispr_constructs do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :crispr_modifications do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :documents do
      get :download, on: :member
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :document_types do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :donors do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :donor_constructs do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :gels do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :gel_images do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :gel_lanes do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :immunoblots do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end
    
    resources :pcrs do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end
    
    resources :antibodies do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :nucleic_acid_terms do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :libraries do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :library_fragmentation_methods do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :paired_barcodes do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :plates do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :sequencing_centers do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :sequencing_library_prep_kits do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :sequencing_platforms do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :sequencing_requests do
      get :get_library_barcode_sequence_hash, on: :member
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :sequencing_runs do
      get :library_sequencing_result, on: :member
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :sequencing_results do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :shippings do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :single_cell_sortings do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :targets do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end
    
    resources :primers do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :treatments do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end
    resources :treatment_term_names do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :vendors do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

    resources :users, only: [:show, :edit] do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
      patch :generate_api_key, on: :member
      patch :remove_api_key, on: :member
      patch :archive, on: :member
      patch :unarchive, on: :member
    end

    resources :wells do
      post :find_by, on: :collection
      post :find_by_or, on: :collection
    end

  end

  namespace :admin do
    root "application#index"

    resources :users do
      member do
        patch :archive
        patch :unarchive
        get  :show_api_key
        post  :remove_api_key
      end
    end
  end

  resources :sequencing_requests do
    get  :libraries_index, on: :member
    get :select_scs, on: :member
    get :select_scs_plates, on: :member
    get :select_library, on: :member
    resources :sequencing_runs do
      get :add_data_storage, on: :collection
      get :new_sequencing_result, on: :member
      resources :sequencing_results do
        get :get_barcode_selector, on: :collection
        get :get_library_selector, on: :collection
      end
    end
  end

  #Add non-nested index view for sequencing_runs:
  #get sequencing_runs: "sequencing_runs#all", as: :sequencing_runs

  devise_for :users, controllers: {
    registrations: 'registrations'
  }
  resources :users, only: [:show, :edit] do
    get :select_options, on: :collection
    post :generate_api_key, on: :member
    get  :show_api_key, on: :member
    post  :remove_api_key, on: :member
    patch :archive, on: :member
  end


  resources :attachments, only: [:show,:new]

  resources :welcome, only: [:index] do
    get :modal_for_image, on: :collection
  end

  resources :reference_genomes do
    resources :chromosomes, except: [:index]
  end

  resources :experiment_types

  resources :sequencing_platforms do
    get :select_options, on: :collection
  end

  resources :libraries do
    get :select_options, on: :collection
    get :select_paired_barcode, on: :collection
    get :select_barcode, on: :collection
  end

  resources :antibodies do
    get :select_options, on: :collection
  end

  resources :antibody_purifications do
    get :select_options, on: :collection
  end

  resources :organisms

  resources :targets do
    get :select_options, on: :collection
  end

  resources :isotypes do
    get :select_options, on: :collection
  end

  resources :biosamples do
    get :select_biosample_libraries, on: :member 
    get :add_shipping, on: :member
    get :add_crispr_modification, on: :member
    get :clone, on: :member
    post :create_clones, on: :member
    get :biosample_children, on: :member
    get :prototype_instances, on: :member
    get :select_options, on: :collection
    get :select_biosample_term_name, on: :collection
  end

  resources :donors do
    get :select_options, on: :collection
  end

  resources :vendors do
    get :select_options, on: :collection
  end

  resources :documents do
    get :select_options, on: :collection
    post :save, on: :collection
    get  :document, on: :member
  end

  resources :document_types

  resources :biosample_types do
    get :select_options, on: :collection
  end

  resources :nucleic_acid_terms

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
   root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
