# Project by Jesper Kirial and Niklas Buhl

# Too add to Sketchup on Niklas

  # UI.menu.add_item("G-Code") { load("/Users/nbxyz/Develop/Sketchup-Gcode-5-Axis-Laser-Cutter/main.rb");}

# Too add to Sketchup on Jesper

  #     UI.menu.add_item("G-Code") { load("C:\\Projects\\Sketchup-Gcode-5-Axis-Laser-Cutter\\main.rb");}

# Z is the up axis

require 'sketchup'
# require 'os' # https://rubygems.org/gems/os // How to add it into the Skethcup path

require_relative 'analysemodel'
require_relative 'analysefaces'
require_relative 'analysecuttingfaces'
require_relative 'calculatecuttingstrategy'
require_relative 'calculatecuttingstrategyv2'
require_relative 'settings'
require_relative 'pathalgorithm'

module Main

  # Hello World

  puts "Hello World. v0.3 - UpdateExtension working on mac"

  # Includes

  include AnalyseModel
  include AnalyseFaces
  include AnalyseCuttingFaces
  include PathAlgorithm
  include CalculateCuttingStrategy
  include CalculateCuttingStrategyV2


  # Model and Layers

  $model
  #$modelClone
  $entities
  $layers

  # Face Arrays

  $edgeArray = Array.new # Collect all edges
  $faceArray = Array.new # Keep track of found faces
  $cuttingArray = Array.new # Keep track of the faces to be cut
  $cuttingStrategy = Array.new # Keep track of cutting strategies


  $analysedArray = Array.new # Keep the CuttingFace class in array
  $cuttingStrategiesArray = Array.new # Keep track for the cutting strategies

  # Primary Methods

  # ---

  def self.main_method

    puts "Hello Main Method"

  end

  def self.AnalyseModel

    t1 = Time.now

    puts "Analysing model to find faces..."

    # Updating all sketchup entities
    $model = Sketchup.active_model
    $entities = $model.active_entities
    $layers = $model.layers

    # Clear faceArray and cuttingArray
    $faceArray.clear
    $edgeArray.clear
    $cuttingArray.clear

    # Analyse model for faces
    AnalyseModel.FindFaces $model.entities

    # Color found faces green
    AnalyseModel.FoundFaces $faceArray

    puts "#{$faceArray.count} faces found!"
    puts "#{$edgeArray.count} edges found!"

    t2 = Time.now

    puts "Model analysed! It took #{t2 - t1} seconds."

  end

  def self.AnalyseFaces

    puts "Analysing faces..."

    t1 = Time.now

    $faceArray.each do |face|

      # Check for top and bottom
      next if AnalyseFaces.TopBottom face

      # Check for faces with too many vertices
      next if AnalyseFaces.TooManyVertices face

      # Check if faces is too angled
      next if AnalyseFaces.TooAngled face

      # Rest of faces is cutting faces
      AnalyseFaces.CutThisFace face, $cuttingArray # Function to color remaining red and put them into cutting faces array

    end

    puts "Analysed found faces!"

    puts "#{$cuttingArray.count} faces to cut!"

    t2 = Time.now

    puts "Faces Analysed! It took #{t2 - t1} seconds."

  end

  def self.CalculateCuttingStrategyV2

    puts "Calculating cutting faces..."

    t1 = Time.now

    $cuttingStrategy = Array.new
    $cuttingStrategy.clear

    $cuttingArray.each do |cuttingFace|

      # -- Cutting Strategy 1

      # 1. Find OuterVertices

      outerVertices = Array.new()

      # 2. Generate cutting lines from outer vertices into Lines[0,1]

      # 3. Raytest: Lines[0] & Line [i], if true, save and next face

      # --- Cutting Strategy 2

      # 4. For each outer vertex

      outerVertices.each_with_index do |outerVertex, index|

        # 4.1 Find cuttable edge from outerVertex

        edges = outerVertex.edges

        edges.each do |edge|

          # 4.4.1 Check if the edge is on the face
          next unless edge.used_by(cuttingFace)

          # 4.4.2 Check if the edge is less that 45 degress
          next if edge.line[1].angle_between(Geom::Vector.new(0,0,0)) > Math::PI / 2

          # 4.4.3 Check if the edge is more that 135 degress
          next if edge.line[1].angle_between(Geom::Vector.new(0,0,0)) < 3 * Math::PI / 4

          # 4.4.3 Generate cutting line from edge(vector) and outer vertex Lines[index]

          # 4.4.4 Raytest: Lines[index]: If true, continue
          cuttingFace.vertices.each do |faceVertex|

            # 4.4.4.1 Check if the vertex is used by the original edge
            next if faceVertex.used_by(edge)

            # 4.4.4.2 Generate cutting line from the vertex and vector from the edge

            # 4.4.4.3 Raytest: Outer vertex cutting line and cutting line from the vertices

        end





        # 4.4 For other vertices not connected to the edge



      end



      # --- Cutting Strategy 3 (Viften)



    end

  end

  def self.AnalyseCuttingFaces

    puts "Analysing cutting faces..."

    t1 = Time.now

    $analysedArray = Array.new

    # Clear analysedArray
    $analysedArray.clear

    new_layer = $layers.add "Analysing Layer"

    # Analyse each face
    $cuttingArray.each do |cuttingFace|

      thisCuttingFace = CuttingFace.new cuttingFace

      # Analyse top and bottom vertices
      AnalyseCuttingFaces.TopBottomZ thisCuttingFace

      # Analysing angle offset
      AnalyseCuttingFaces.XYAngleOffset thisCuttingFace

      # Analysing most side vertices
      AnalyseCuttingFaces.SideVertices thisCuttingFace

      # Edges available as start/end cutting vectors
      #AnalyseCuttingFaces.AvailableCuttingEdges thisCuttingFace

      # Find a vector parallel to the plane in rectangular to the normal vector upwards
      #AnalyseCuttingFaces.PlaneVector thisCuttingFace

      $analysedArray.push(thisCuttingFace)

    end

    t2 = Time.now

    puts "#{$analysedArray.count} cutting faces analysed! It took #{t2 - t1} seconds."

  end

  def self.PathAlgorithm

    $faceArray.each do |face|

      PathAlgorithm.Findpoints face
    # make an array with the points of the found faces

    end

  end


  def self.CalculateCuttingStrategy

    puts "Calculating cutting strategy for each cutting face..."

    t1 = Time.now

    $cuttingStrategiesArray.clear

    $cuttingArray.each do |cuttingFace|

      tempFaceCuttingStrategy = FaceCuttingStrategy.new

      # Test cutting strategy 1

      # Test cutting strategy 2A

      # Test cutting strategy 2B

      # Test cutting strategy 3

    end

    t2 = Time.now

    puts "Cutting strategy calculated! It took #{t2 - t1} seconds."

  end

  def self.CalculateTrajectory

    puts "Calculating Trajectory..."

    # Calculate shortest path between vectors

    puts "Trajectory Calculated!"

  end

  def self.GenerateGCode

    puts "Generating GCode..."

  end

  def self.ExportGCode

    puts "Export GCode..."

  end

  # ---

  # Developer Utilities

  # ---

  def self.GenerateTestModels

    puts "Generate Test Models. v0.2"

    model = Sketchup.active_model

    testModelPath = File.join(File.dirname(__FILE__),'/test-geometrier-laser.skp')

    model.import(testModelPath)

  end

  def self.GenerateSimpleTestModel

    puts "Generate Simple Test Model. v0.1"

    model = Sketchup.active_model

    testModelPath = File.join(File.dirname(__FILE__),'/test-simplemodel.skp')

    model.import(testModelPath)

  end

  def self.UpdateExtensionOSX

    puts "Updating modules. v1.0"

    projectdir = File.dirname(__FILE__)

    load projectdir + "/settings.rb"
    load projectdir + "/analysemodel.rb"
    load projectdir + "/analysefaces.rb"
    load projectdir + "/analysecuttingfaces.rb"
    load projectdir + "/calculatecuttingstrategy.rb"

    # puts projectdir

  end

  # ---

  # User Interface Dropdown Menu

  # ---

  unless file_loaded?(__FILE__)

    menu = UI.menu('Plugins')

    menu.add_item('Analyse Model') {self.AnalyseModel}
    menu.add_item('Analyse Faces') {self.AnalyseFaces}
    menu.add_item('Analyse Cutting Faces') {self.AnalyseCuttingFaces}
    menu.add_item('Calculate Cutting Strategy') {self.CalculateCuttingStrategy}
    menu.add_item('Calculate Cutting Trajectory') {self.CalculateCuttingTrajectory}
    menu.add_item('Generate GCode') {self.GenerateGCode}
    menu.add_item('Export GCode') {self.ExportGCode}
    menu.add_item('Find points in faces') {self.PathAlgorithm}

    # Remove everything and generate test models (Used for development purposes)
    menu.add_item('Generate Test Models') {self.GenerateTestModels}
    menu.add_item('Generate Simple Test Model') {self.GenerateSimpleTestModel}

    # To remove extension (Used for development purposes)
    menu.add_item('Update Extension') {self.UpdateExtensionOSX}

    file_loaded(__FILE__)

  end

  # ---

  # User Interface Toolbar

  # ---

  # Create new toolbar with buttons.

=begin
  toolbar = UI::Toolbar.new "5 Axis Lasercutter"

  cmd = UI::Command.new("Analyse Model") { AnalyseModel }
  toolbar.add_item cmd

  toolbar = toolbar.add_separator
  cmd = UI::Command.new("Analyse Cutting Faces") { AnalyseCuttingFaces }
  toolbar.add_item cmd

  toolbar = toolbar.add_separator
  cmd = UI::Command.new("Calculate Cutting Strategy") { CalculateCuttingStrategy }
  toolbar.add_item cmd

  toolbar = toolbar.add_separator
  cmd = UI::Command.new("Generate GCode") { GenerateGCode }
  toolbar.add_item cmd

  toolbar = toolbar.add_separator
  cmd = UI::Command.new("Export GCode") { ExportGCode }
  toolbar.add_item cmd

  toolbar = toolbar.add_separator
  cmd = UI::Command.new("Generate Test Models") { GenerateTestModels }
  toolbar.add_item cmd

  toolbar = toolbar.add_separator
  cmd = UI::Command.new("Update Extension") { UpdateExtension }
  toolbar.add_item cmd

  toolbar.show

  toolbar.each { | item |
    puts item
  }
=end

end
