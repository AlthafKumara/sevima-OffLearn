export const getSampleData = async (req, res) => {
  try {
    // You can add your logic here, e.g., fetching from Prisma or Supabase
    res.status(200).json({
      success: true,
      data: {
        id: 1,
        title: 'Sample Data for Offlearn',
        description: 'This is a sample response.'
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};
