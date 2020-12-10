#include <iostream>

#include <boost/program_options.hpp>
#include <boost/foreach.hpp>
#include <boost/property_tree/ptree.hpp> // ptree
#include <boost/property_tree/xml_parser.hpp>
#include <boost/filesystem.hpp> // path, extension
#include <boost/regex.hpp> // regex
#include <boost/algorithm/string.hpp> // iequals
#include <boost/range/algorithm.hpp>
#include <boost/algorithm/string.hpp> // str replace

#include "opencv2/core/core.hpp"
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/calib3d/calib3d.hpp"
#include <opencv2/nonfree/features2d.hpp>

using namespace cv;
using namespace boost;
using namespace boost::program_options;
using namespace boost::property_tree;
using namespace boost::filesystem;
using namespace std;

int main(int argc, char* argv[])
{
	string inputFile;
	string inputFile2;
	string outputFile;
	string outputDescriptors;

	string detector = "SIFT";
	string descriptor = "SIFT";

	double matchingThreshold = -1;
	bool homographyValidation = true;
	int validationThreshold = 10;
	bool binaryMatcher = false;
	bool verbose = true;
	int scalingSize = 300;
	int bestMatches = 5;
	int denseSize = 6;
	// Take inputs
	options_description desc("Allowed options");
	desc.add_options()("help,h", "produce help message")
		("detector,d", value<string>(), "set detector")
		("descriptor,s", value<string>(), "set descriptor")
		("densesize,e", value<int>(), "set Dense detector size")
		("input1,i", value<string>(), "set input file")
		("verbose,V", value<bool>(), "verbose output")
		("output,o", value<string>(), "set output image file")
		("descfile,p", value<string>(), "set output file for descriptors");
	try {
		variables_map vm;
		store(parse_command_line(argc, argv, desc), vm);
		notify(vm);

		if(vm.count("help"))
		{
			cout << desc << endl;
			return 1;
		}
		if(vm.count("input1"))
		{
			inputFile = vm["input1"].as<string>();
		}
		else
		{
			cout << desc << endl;
			return 1;
		}
		if(vm.count("output"))
		{
			outputFile = vm["output"].as<string>();
		}
		if(vm.count("verbose"))
		{
			verbose = vm["verbose"].as<bool>();
		}
		if(vm.count("densesize"))
		{
			denseSize = vm["densesize"].as<int>();
		}

		if(vm.count("detector"))
		{
			detector = vm["detector"].as<string>();
		}
		if(vm.count("descriptor"))
		{
			descriptor = vm["descriptor"].as<string>();
		}
		if(vm.count("descfile"))
		{
			outputDescriptors = vm["descfile"].as<string>();
		}
	}
	catch(std::exception& e)
	{
		cerr << "Error!!! " << e.what() << endl;
		return 1;
	}
	catch(...)
	{
		cerr << "Exception of unknown type!" << endl;
	}

	cv::Ptr<cv::FeatureDetector> featureDetector;
	cv::Ptr<cv::DescriptorExtractor> descriptorExtractor;

	if(detector.compare("SIFT") == 0)
	{
		featureDetector = new SiftFeatureDetector;
	}
	else if(detector.compare("SURF") == 0)
	{
		featureDetector = new SurfFeatureDetector;
	}
	else if(detector.compare("Dense") == 0)
	{
		featureDetector = new DenseFeatureDetector( denseSize * 2, 1, 0.1f, denseSize, 0, false, false);  
	}
	else
	{
		featureDetector = FeatureDetector::create(detector);
		if(featureDetector == NULL)
		{
			cerr << "FeatureDetector Failed for " << detector << endl;
			cerr << "Check: http://docs.opencv.org/modules/features2d/doc/common_interfaces_of_feature_detectors.html#featuredetector-create" << endl;
			exit(-1);
		}
	}

	if(descriptor.compare("SIFT") == 0)
	{
		descriptorExtractor = new SiftDescriptorExtractor;
	}
	else if(descriptor.compare("SURF") == 0)
	{
		descriptorExtractor = new SurfDescriptorExtractor;
	}
	else
	{
		descriptorExtractor = DescriptorExtractor::create(descriptor);
		if(descriptorExtractor == NULL)
		{
			cerr << "DescriptorExtractor Failed for " << descriptor << endl;
			cerr << "Check: http://docs.opencv.org/modules/features2d/doc/common_interfaces_of_descriptor_extractors.html#descriptorextractor-create" << endl;
			exit(-1);
		}
		binaryMatcher = true;
	}

	// Read images
	vector<KeyPoint> keypoints1;     // Keypoints

	// Detect interest points
	Mat descriptors1;

	double scale = 0;

	Mat img1 = cv::imread(inputFile);
	cv::cvtColor(img1, img1, CV_BGR2GRAY);
	if(scalingSize > 0)
	{
		//scale = (double)img1.rows / (double)img1.cols;
		//resize(img1, img1, Size(scalingSize/scale, scalingSize));
		featureDetector->detect(img1, keypoints1);
		descriptorExtractor->compute(img1, keypoints1, descriptors1);
	}

	Mat img_desc;
	if(verbose)
	{
		cout << "Feature statistics:" << endl;
		cout << "-- Features in scene1: " << descriptors1.rows << endl;

		drawKeypoints(img1, keypoints1, img_desc, Scalar::all(-1), DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
		imshow( "Descriptors", img_desc );
		
		cout << "Press key to continue..." << endl;
		cv::waitKey(0);
	}
	if(outputFile.compare("") != 0)
	{
		if(verbose)
			cout << "Saving the image to " << outputFile << "..." << endl;
		
		drawKeypoints(img1, keypoints1, img_desc, Scalar::all(-1), DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
		cv::imwrite(outputFile, img_desc);
	}
	if(outputDescriptors.compare("") != 0)
	{
		if(verbose)
			cout << "Saving the descriptors to " << outputDescriptors << "..." << endl;
		// itereate through descriptors
		boost::filesystem::path destPath(outputDescriptors);
		
		ofstream ofs;
		ofs.open(destPath.string().c_str());

		ofs << keypoints1.size() << " " << descriptors1.cols << endl;
		for(unsigned int i = 0; i < keypoints1.size(); i++ )
		{
			KeyPoint kp = keypoints1[i];
			//ofs << kp.pt.x << " " << kp.pt.y << " " << kp.size << " " << kp.angle << "   ";
			ofs << kp.pt.x << " " << kp.pt.y << " " << kp.size << " " << kp.angle << "   ";
			Mat row = descriptors1.row(i);
			for(unsigned int j = 0; j < descriptors1.cols; j++ )
			{
				if(descriptors1.type() == CV_32F)
				{
					ofs << row.at<float>(j) << " ";
				}
				if(descriptors1.type() == CV_8U)
				{
					ofs << (int)row.at<unsigned char>(j) << " ";
				}
			}
			ofs << endl;
		}
		ofs.close();
	}


	return 0;
}
